$(document).ready(function () {
    //get URL parameters, from http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
    var urlParams = {
        'letter': $('#letters').text().split(',')
    };    

    $('#search_button').click(function () {
        var query = new Array();
        var type = $('#type_filter').val();
        var role = $('#role_filter').val();
        var field = $('#field_filter').val();
        var conceptScheme = $('#conceptScheme_filter').val();
        var text = $('#search_text').val();
        
        if (type.length > 0) {
            query.push(type);
        }
        if (field.length > 0) {
            query.push(field);
        }
        if (conceptScheme.length > 0) {
            query.push(conceptScheme);
        }
        if (text.length > 0) {
            query.push(text);
        }
        if (role.length > 0 && $('#role_filter').prop('disabled') == false) {
            query.push(role);
        }
        
        $('.letter-button').each(function () {
            if ($(this).hasClass('active')) {
                query.push('letter_facet:"' + $(this).text() + '"');
            }
        });
        
        if (query.length > 0) {
            $('#filter-form').children('input[name=q]').attr('value', query.join(' AND '));
        }
        
        if ($('#sort_results').val().length > 0) {
            $('#filter-form').children('input[name=sort]').prop('disabled', false);
            $('#filter-form').children('input[name=sort]').attr('value', $('#sort_results').val());
        }
    });
    
    $('.letter-button').click(function () {
        if ($(this).hasClass('active')) {
            $(this).removeClass('active');
            return false;
        } else {
            $(this).addClass('active');
            return false;
        }
    });
    
    //clear selected letters
    $('#clear_letter_button').click(function () {
        $('.letter-button').each(function () {
            $(this).removeClass('active');
        });
        return false;
    });
    
    //disable inputs, reset form
    $('#clear-query').click(function () {
        $('#filter-form').children('input[name=sort]').prop('disabled', true);
        $('#filter-form').children('input[name=q]').prop('disabled', true);
        $('#filter-form').children('input[name=layout]').prop('disabled', true);
    });
    
    $('.toggle-button').click(function () {
        var div_id = $(this).attr('id').split('-')[1] + '-div';
        if ($(this).children('span#toggle-glyphicon').hasClass('glyphicon-triangle-bottom')) {
            $(this).children('span#toggle-glyphicon').removeClass('glyphicon-triangle-bottom');
            $(this).children('span#toggle-glyphicon').addClass('glyphicon-triangle-right');
        } else {
            $(this).children('span#toggle-glyphicon').removeClass('glyphicon-triangle-right');
            $(this).children('span#toggle-glyphicon').addClass('glyphicon-triangle-bottom');
        }
        $('#' + div_id).toggle('fast');
        return false;
    });
    
    $('#type_filter').change(function () {
        var val = $(this).val();
        
        if (val.indexOf('Person') > 0 || val.indexOf('Organization') > 0) {
            $('.role_div').show();
            $('#role_filter').prop('disabled', false);
        } else {
            $('.role_div').hide();
            $('#role_filter').prop('disabled', true);
        }
    });
    
    $("#map_results").fancybox({
        beforeShow: function () {
            if ($('#resultMap').html().length == 0) {
                $('#resultMap').html('');
                initialize_map(urlParams);
                return false
            }
        }
    });
});

function initialize_map(urlParams) {
    
    var mapboxKey = $('#mapboxKey').text();
    
    //baselayers
    var osm = L.tileLayer(
    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'OpenStreetMap',
        maxZoom: 10
    });
    
    var imperium = L.tileLayer(
    'https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {
        maxZoom: 10,
        attribution: 'Powered by <a href="http://leafletjs.com/">Leaflet</a>. Map base: <a href="https://dh.gu.se/dare/" title="Digital Atlas of the Roman Empire, Department of Archaeology and Ancient History, Lund University, Sweden">DARE</a>, 2015 (cc-by-sa).'
    });
    var mb_physical = L.tileLayer(
    'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://mapbox.com">Mapbox</a>', id: 'mapbox/outdoors-v11', maxZoom: 12, accessToken: mapboxKey
    });
    
    var map = new L.Map('resultMap', {
        center: new L.LatLng(0, 0),
        zoom: 4,
        layers:[mb_physical]
    });
    
    //add mintLayer from AJAX
    var mintLayer = L.geoJson.ajax('./apis/getMints?' + $.param(urlParams, true), {
        onEachFeature: onEachFeature,
        pointToLayer: renderPoints
    }).addTo(map);
    
    //add hoards, but don't make visible by default
    var hoardLayer = L.geoJson.ajax('./apis/getHoards?' + $.param(urlParams, true), {
        onEachFeature: onEachFeature,
        pointToLayer: renderPoints
    }).addTo(map);
    
    var findLayer = L.geoJson.ajax('./apis/getFindspots?' + $.param(urlParams, true), {
        onEachFeature: onEachFeature,
        pointToLayer: renderPoints
    }).addTo(map);
    
    //add controls
    var baseMaps = {
        "Terrain and Streets": mb_physical,
        "Modern Streets": osm,
        "Imperium": imperium
    };
    
    var overlayMaps = {
        'Mints': mintLayer, 'Hoards': hoardLayer, 'Finds': findLayer
    };
    
    L.control.layers(baseMaps, overlayMaps).addTo(map);
    
    //zoom to groups on AJAX complete
    mintLayer.on('data:loaded', function () {
        var group = new L.featureGroup([mintLayer, hoardLayer, findLayer]);
        map.fitBounds(group.getBounds());
    }.bind(this));
    
    hoardLayer.on('data:loaded', function () {
        var group = new L.featureGroup([mintLayer, hoardLayer, findLayer]);
        map.fitBounds(group.getBounds());
    }.bind(this));
    
    findLayer.on('data:loaded', function () {
        var group = new L.featureGroup([mintLayer, hoardLayer, findLayer]);
        map.fitBounds(group.getBounds());
    }.bind(this));
    
    /*****
     * Features for manipulating layers
     *****/
    function renderPoints(feature, latlng) {
        var fillColor;
        switch (feature.properties.type) {
            case 'mint':
            fillColor = '#6992fd';
            break;
            case 'hoard':
            fillColor = '#d86458';
            break;
            case 'find':
            fillColor = '#a1d490';
        }
        
        return new L.CircleMarker(latlng, {
            radius: 5,
            fillColor: fillColor,
            color: "#000",
            weight: 1,
            opacity: 1,
            fillOpacity: 0.6
        });
    }
    
    function onEachFeature (feature, layer) {
        var str;
        //individual finds
        if (feature.properties.hasOwnProperty('gazetteer_uri') == false) {
            str = feature.label;
        } else {
            var str = '';
            //display hoard link and gazetteer link
            if (feature.hasOwnProperty('id') == true) {
                str += '<a href="' + feature.id + '">' + feature.label + '</a><br/>';
            }
            if (feature.properties.hasOwnProperty('gazetteer_uri') == true) {
                str += '<span>';
                if (feature.properties.type == 'hoard') {
                    str += '<b>Findspot: </b>';
                }
                str += '<a href="' + feature.properties.gazetteer_uri + '">' + feature.properties.toponym + '</a></span>'
            }
            if (feature.properties.hasOwnProperty('closing_date') == true) {
                str += '<br/><span>';
                str += '<b>Closing Date: </b>' + feature.properties.closing_date;
            }
        }
        layer.bindPopup(str);
    }
}