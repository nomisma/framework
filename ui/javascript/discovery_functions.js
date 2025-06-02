$(document).ready(function () {
    initialize_map();
    
    var path = $('#path').text();
    
    /**** FORM MANIPULATION AND VALIDATION ****/
    //on changing between viewing all points for one query or comparing queries for one geographic category
    $('input[type=radio][name=compareBy]').change(function () {
        var formId = $(this).closest('form').attr('id');
        
        if ($(this).val() == 'all') {
            //hide all controls related to adding multiple queries
            $('.remove-dataset').addClass('hidden');
            $('.add-compare').addClass('hidden');
            
            //hide color picker
            $('#' + formId).find('input[type=color]').addClass('hidden');
            $('#' + formId).find('input[type=color]').attr('disabled', 'disabled');
            
            //remove all compare containers except for the first one
            $('.compare-master-container').children('.compare-container').not(':first').remove();
        } else {
            //show controls for adding compare queries
            $('.remove-dataset').removeClass('hidden');
            $('.add-compare').removeClass('hidden');
            
            //enable color picker
            $('#' + formId).find('input[type=color]').removeClass('hidden');
            $('#' + formId).find('input[type=color]').removeAttr('disabled');
        }
        
        validate(formId);
    });
    
    //when clicking the add-filter link, insert a new filter template into the filter container
    $('.add-filter').click(function () {
        var container = $(this).closest('form').find('.filter-container');
        var formId = $(this).closest('form').attr('id');
        var type = $('#type').text();
        if (type.indexOf('foaf') >= 0) {
            type = 'foaf:Person|foaf:Organization';
        }
        $('#field-template').clone().removeAttr('id').appendTo(container);
        //work on removing the option for the current class
        $('.filter-container').find('option[type="' + type + '"]').remove();
        validate(formId);
        return false;
    });
    
    /***COMPARE***/
    //add dataset for comparison
    $('.add-compare').click(function () {
        var container = $(this).closest('form').find('.compare-master-container');
        var formId = $(this).closest('form').attr('id');
        $('#compare-container-template').clone().removeAttr('id').appendTo(container);
        
        
        //automatically insert a property-object query pair
        $('#field-template').clone().removeAttr('id').appendTo('.compare-master-container .compare-container:last');
        
        //enable color picker
        $('#' + formId).find('input[type=color]').removeClass('hidden');
        $('#' + formId).find('input[type=color]').removeAttr('disabled');
        
        validate(formId);
        return false;
    });
    //add property-object facet into dataset
    $('.compare-master-container').on('click', 'h4 small .add-compare-field', function () {
        $('#field-template').clone().removeAttr('id').appendTo($(this).closest('.compare-container'));
        var formId = $(this).closest('form').attr('id');
        validate(formId);
        
        var count = $(this).closest('.compare-container').children('.filter').length;
        
        //toggle the alert box when there aren't any filters
        if (count > 0) {
            $(this).closest('.compare-container').children('.empty-query-alert').addClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.empty-query-alert').removeClass('hidden');
        }
        
        return false;
    });
    
    //get facets on property drop-down list change
    $('.compare-master-container').on('change', '.compare-container .filter .add-filter-prop', function () {
        var prop = $(this).val();
        var type = $(this).children('option:selected').attr('type');
        var next = $(this).next('.prop-container');
        
        var q = new Array();
        //get the filter query from previous parameters
        $(this).parent('.filter').prevAll('.filter').each(function () {
            pair = parseFilter($(this));
            if (pair.length > 0) {
                q.push(pair);
            }
        });
        filter = q.join('; ');
        
        //if the prop is a from or do date, insert date entry template, otherwise get facets from SPARQL
        if (prop == 'from' || prop == 'to') {
            addDate(next);
        } else {
            getFacets(filter, prop, type, next, path);
        }
        
        //display duplicate property alert if there is more than one from or to date
        duplicates = countDates($(this).closest('.compare-container'));
        if (duplicates == true) {
            $(this).closest('.compare-container').children('.duplicate-date-alert').removeClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.duplicate-date-alert').addClass('hidden');
        }
    });
    
    //validate on object drop-down list change
    $(' .compare-master-container').on('change', '.compare-container .filter .prop-container .add-filter-object', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //delete dataset query
    $(' .compare-master-container').on('click', '.compare-container h4 small .remove-dataset', function () {
        var formId = $(this).closest('form').attr('id');
        $(this).closest('.compare-container').remove();
        validate(formId);
        return false;
    });
    
    //delete property-object pair
    $(' .compare-master-container').on('click', '.compare-container .filter .control-container .remove-query', function () {
        var formId = $(this).closest('form').attr('id');
        var count = $(this).closest('.compare-container').children('.filter').length;
        
        //toggle the alert box when there aren't any filters
        if (count == 1) {
            $(this).closest('.compare-container').children('.empty-query-alert').removeClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.empty-query-alert').addClass('hidden');
        }
        
        //store the container object to processing after deletion of filter
        var container = $(this).closest('.compare-container');
        $(this).closest('.filter').remove();
        
        //display duplicate property alert if there is more than one from or to date. must count after deletion of filter
        duplicates = countDates(container);
        if (duplicates == true) {
            container.children('.duplicate-date-alert').removeClass('hidden');
        } else {
            container.children('.duplicate-date-alert').addClass('hidden');
        }
        validate(formId);
        return false;
    });
    
    //validate on date change
    $(' .compare-master-container').on('change', '.compare-container .filter .prop-container span input.year', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $(' .compare-master-container').on('change', '.compare-container .filter .prop-container span select.era', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
});

function initialize_map() {
    var prefLabel = $('span[property="skos:prefLabel"]:lang(en)').text();
    var type = $('#type').text();
    var mapboxKey = $('#mapboxKey').text();
    var path = $('#path').text();
    
    //get updated GeoJSON upon submit click
    $('.visualize-submit').click(function () {
        var formId = $(this).closest('form').attr('id');
        var numericType = $('#' + formId).find('input[name=numericType]:checked').val();
        var compareBy = $('#' + formId).find('input[name=compareBy]:checked').val();
        
        if (compareBy == 'all') {
            var query = $('#' + formId).children('input[name=compare]').val();
            var url = path + "apis/query.geojson?query=" + query + "&numericType=" + numericType;
        } else {
            var queries =[];
            $('#' + formId).children('input[name=compare]').each(function () {
                queries.push("compare=" + $(this).val());
            });
            
            var url = path + "apis/query.geojson?" + queries.join('&') + "&numericType=" + numericType + "&type=" + compareBy;
        }
        
        pointLayer.refresh(url);
        
        //close window
        $.fancybox.close();
        
        return false;
    });
    
    $('#close').click(function () {
        $.fancybox.close();
    });
    
    
    //LEAFLET SETUP
    //baselayers
    var mb_physical = L.tileLayer(
    'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://mapbox.com">Mapbox</a>', id: 'mapbox/outdoors-v11', maxZoom: 12, accessToken: mapboxKey
    });
    
    var osm = L.tileLayer(
    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'OpenStreetMap',
        maxZoom: 18
    });
    
    var imperium = L.tileLayer(
    'https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {
        maxZoom: 10,
        attribution: 'Powered by <a href="http://leafletjs.com/">Leaflet</a>. Map base: <a href="https://dh.gu.se/dare/" title="Digital Atlas of the Roman Empire, Department of Archaeology and Ancient History, Lund University, Sweden">DARE</a>, 2015 (cc-by-sa).'
    });
    
    var map = new L.Map('mapcontainer', {
        center: new L.LatLng(0, 0),
        zoom: 4,
        layers:[mb_physical]
    });
    
    //add controls
    var baseMaps = {
        "Terrain and Streets": mb_physical,
        "Modern Streets": osm,
        "Imperium": imperium
    };
    
    var pointLayer = L.geoJson.ajax('', {
        onEachFeature: renderPopup,
        style: function (feature) {
            if (feature.geometry.type == 'Polygon') {
                var fillColor = getFillColor(feature.properties.type);
                
                return {
                    color: fillColor
                }
            }
        },
        pointToLayer: function (feature, latlng) {
            return renderPoints(feature, latlng);
        }
    }).addTo(map);
    
    var overlayMaps = {
        'Points': pointLayer
    };
    
    //zoom to groups on AJAX complete
    pointLayer.on('data:loaded', function () {
        map.fitBounds(pointLayer.getBounds());
    }.bind(this));
    
    L.Control.Button = L.Control.extend({
        options: {
            position: 'topleft'
        },
        onAdd: function (map) {
            var container = L.DomUtil.create('div', 'leaflet-bar leaflet-control');
            var button = L.DomUtil.create('a', 'glyphicon glyphicon-filter', container);
            L.DomEvent.disableClickPropagation(button);
            L.DomEvent.on(button, 'click', function () {
                $.fancybox({
                    'href': '#map_filters'
                });
            });
            
            container.title = "Filter";
            
            return container;
        }
    });
    var control = new L.Control.Button()
    control.addTo(map);
    
    L.control.Legend({
        position: "bottomleft",
        symbolWidth: 24,
        symbolHeight: 24,
        legends: JSON.parse($('#legend').text())
    }).addTo(map);
    
    //add controls
    var layerControl = L.control.layers(baseMaps, overlayMaps).addTo(map);
    
    /*****
     * Features for manipulating layers
     *****/
    function renderPoints(feature, latlng) {
        
        //if there's a compareGroup property, then fetch the color value from the appropriate query group
        if (feature.properties.hasOwnProperty('compareGroup')) {
            var compareIndex = feature.properties.compareGroup - 1;
            fillColor = $('.compare-master-container').find('input[type=color]').eq(compareIndex).val();
        } else {
            //otherwise, select color based on point type
            var fillColor = getFillColor(feature.properties.type);
        }
        
        if (feature.properties.hasOwnProperty('radius')) {
            var radius = feature.properties.radius
        } else {
            var radius = 5;
        }
        
        return new L.CircleMarker(latlng, {
            radius: radius,
            fillColor: fillColor,
            color: "#000",
            weight: 1,
            opacity: 1,
            fillOpacity: 0.6
        });
    }
    
    function getFillColor (type) {
        var fillColor;
        switch (type) {
            case 'mint':
            fillColor = '#6992fd';
            break;
            case 'findspot':
            fillColor = '#f98f0c';
            break;
            case 'hoard':
            fillColor = '#d86458';
            break;
            default:
            fillColor = '#efefef'
        }
        
        return fillColor;
    }
    
    function renderPopup (feature, layer) {
        
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
                str += '<a href="' + feature.properties.gazetteer_uri + '">' + feature.properties.toponym + '</a></span>';
                if (feature.properties.type == 'hoard' && feature.properties.hasOwnProperty('closing_date') == true) {
                    str += '<br/><b>Closing Date: </b>' + feature.properties.closing_date;
                }
            }
            if (feature.properties.hasOwnProperty('count') == true) {
                str += '<br/><b>Count: </b>' + feature.properties.count;
            }
        }
        layer.bindPopup(str);
    }
}