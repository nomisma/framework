$(document).ready(function () {
    initialize_map();
    
    var path = $('#path').text();
    
    /***** FORM MANIPULATION AND VALIDATION *****/
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
    
    /***** COMPARE *****/
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
    
    /***** AJAX RESULTS *****/
    //sorting
    $('#ajaxList').on('click', '#ajaxList-div table thead tr th .sort-types', function () {
        urlParams = {
        };
        
        var numericType = $('#geoForm').find('input[name=numericType]:checked').val();
        if (numericType == 'object') {
            var api = 'listObjects';
        } else if (numericType == 'coinType') {
            var api = 'listTypes';
        }
        
        //parse the page and sort from the HTML link
        var match,
        pl = /\+/g, // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) {
            return decodeURIComponent(s.replace(pl, " "));
        },
        query = $(this).attr('href').substring(1);
        
        compare = new Array();
        while (match = search.exec(query)) {
            urlParams[decode(match[1])] = decode(match[2]);
        }
        
        $. get (path + 'ajax/' + api, $.param(urlParams, true),
        function (data) {
            $('#ajaxList').html(data);
        });
        
        return false;
    });
    
    //paginating ajax results
    $('#ajaxList').on('click', '.paging_div .page-nos .btn-toolbar .btn-group a.btn', function (event) {
        urlParams = {
        };
        
        var numericType = $('#geoForm').find('input[name=numericType]:checked').val();
        if (numericType == 'object') {
            var api = 'listObjects';
        } else if (numericType == 'coinType') {
            var api = 'listTypes';
        }
        
        //parse the page and sort from the HTML link
        var match,
        pl = /\+/g, // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) {
            return decodeURIComponent(s.replace(pl, " "));
        },
        query = $(this).attr('href').substring(1);
        
        compare = new Array();
        while (match = search.exec(query)) {
            urlParams[decode(match[1])] = decode(match[2]);
        }
        
        $. get (path + 'ajax/' + api, $.param(urlParams, true),
        function (data) {
            $('#ajaxList').html(data);
        });
        return false;
    });
    
    //show/hide sections
    $('#ajaxList').on('click', 'h3 small .toggle-button', function () {
        var div = $(this).attr('id').split('-')[1];
        $('#' + div + '-div').toggle();
        
        //replace minus with plus and vice versa
        var span = $(this).children('span');
        if (span.attr('class').indexOf('right') > 0) {
            span.removeClass('glyphicon-triangle-right');
            span.addClass('glyphicon-triangle-bottom');
        } else {
            span.removeClass('glyphicon-triangle-bottom');
            span.addClass('glyphicon-triangle-right');
        }
        return false;
    });
    
    //toggle divs to be hidden or shown (SPARQL query)
    $('#ajaxList').on('click', '.control-row .toggle-button', function () {
        var div = $(this).attr('id').split('-')[1];
        $('#' + div + '-div').toggle();
        
        //replace minus with plus and vice versa
        var span = $(this).children('span');
        if (span.attr('class').indexOf('minus') > 0) {
            span.removeClass('glyphicon-minus');
            span.addClass('glyphicon-plus');
        } else {
            span.removeClass('glyphicon-plus');
            span.addClass('glyphicon-minus');
        }
        return false;
    });
    
    /***** PERMALINK *****/
    $('#permalink').click(function () {
        var url = window.location.href.split('?')[0] + '?' + $(this).attr('href').split('?')[1];
        navigator.clipboard.writeText(url);
        
        $('#permalink-tooltip').fadeIn(3);
        $('#permalink-tooltip').fadeOut();
        
        return false;
    });
    
    /***** IMAGE POPUPS WITHIN AJAX RESULTS *****/
    $('a.thumbImage').fancybox({
        type: 'image',
        beforeShow: function () {
            this.title = '<a href="' + this.element.attr('id') + '">' + this.element.attr('title') + '</a>'
        },
        helpers: {
            title: {
                type: 'inside'
            }
        }
    });
    
    $('.iiif-image').fancybox({
        beforeShow: function () {
            var manifest = this.element.attr('manifest');
            this.title = '<a href="' + this.element.attr('id') + '">' + this.element.attr('title') + '</a>'
            //remove and replace #iiif-container, if different or new
            if (manifest != $('#manifest').text()) {
                $('#iiif-container').remove();
                $(".iiif-container-template").clone().removeAttr('class').attr('id', 'iiif-container').appendTo("#iiif-window");
                $('#manifest').text(manifest);
                render_image(manifest);
            }
        },
        helpers: {
            title: {
                type: 'inside'
            }
        }
    });
    
    function render_image(manifest) {
        var iiifImage = L.map('iiif-container', {
            center:[0, 0],
            crs: L.CRS.Simple,
            zoom: 0
        });
        
        // Grab a IIIF manifest
        $.getJSON(manifest, function (data) {
            //determine where it is a collection or image manifest
            if (data[ '@context'] == 'http://iiif.io/api/image/2/context.json' || data[ '@context'] == 'http://library.stanford.edu/iiif/image-api/1.1/context.json') {
                L.tileLayer.iiif(manifest).addTo(iiifImage);
            } else if (data[ '@context'] == 'http://iiif.io/api/presentation/2/context.json') {
                var iiifLayers = {
                };
                
                // For each image create a L.TileLayer.Iiif object and add that to an object literal for the layer control
                $.each(data.sequences[0].canvases, function (_, val) {
                    iiifLayers[val.label] = L.tileLayer.iiif(val.images[0].resource.service[ '@id'] + '/info.json');
                });
                // Add layers control to the map
                L.control.layers(iiifLayers).addTo(iiifImage);
                
                // Access the first Iiif object and add it to the map
                iiifLayers[Object.keys(iiifLayers)[0]].addTo(iiifImage);
            }
        });
    }
});

function initialize_map() {
    var type = $('#type').text();
    var mapboxKey = $('#mapboxKey').text();
    var path = $('#path').text();
    
    //get updated GeoJSON upon submit click
    $('.visualize-submit').click(function () {
        var formId = $(this).closest('form').attr('id');
        var numericType = $('#' + formId).find('input[name=numericType]:checked').val();
        var compareBy = $('#' + formId).find('input[name=compareBy]:checked').val();
        var url = '';
        
        if (compareBy == 'all') {
            $('#ajaxList').html('');
            var query = $('#' + formId).children('input[name=compare]').val();
            url = path + "apis/query.geojson?query=" + query + "&numericType=" + numericType;
            
            if (numericType == 'object') {
                var api = 'listObjects';
            } else if (numericType == 'coinType') {
                var api = 'listTypes';
            }
            
            //display ajax results
            $. get (path + 'ajax/' + api, {
                query: query
            },
            function (data) {
                $('#ajaxList').html(data);
            });
        } else {
            var queries =[];
            $('#' + formId).children('input[name=compare]').each(function () {
                queries.push("compare=" + $(this).val());
            });
            
            $('#ajaxList').html('');
            url = path + "apis/query.geojson?" + queries.join('&') + "&numericType=" + numericType + "&type=" + compareBy;
        }
        
        pointLayer.refresh(url);
        
        //update permalink
        $('#permalink').attr('href', 'discover?' + url.split('?')[1]);
        $('#permalink').parent('p').removeClass('hidden');
        
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
    
    //get params, if applicable
    var params = $('#permalink').attr('href').split('?')[1];
    var query = '';
    
    if (params.length > 0) {
        var query = path + 'apis/query.geojson?' + params;
        
        var numericType = $('#numericType').text();
        if (numericType == 'object') {
            var api = 'listObjects';
        } else if (numericType == 'coinType') {
            var api = 'listTypes';
        }
        
        //get AJAX results
        $. get (path + 'ajax/' + api + '?' + params,
        function (data) {
            $('#ajaxList').html(data);
        });
    }
    
    var pointLayer = L.geoJson.ajax(query, {
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
    
    /***** UPDATING MAP FROM LEAFLET POPUP  *****/
    map.on('popupopen', function () {
        $('.updateMap').click(function () {
            var numericType = $('#geoForm').find('input[name=numericType]:checked').val();
            if (numericType == 'object') {
                var api = 'listObjects';
            } else if (numericType == 'coinType') {
                var api = 'listTypes';
            }
            
            $. get (path + 'ajax/' + api + $(this).attr('href'),
            function (data) {
                $('#ajaxList').html(data);
            });
            return false;
        });
    });
    
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
        
        //get the query for the appropriate compare group, if applicable
        if (feature.properties.hasOwnProperty('compareGroup')) {
            var compareIndex = feature.properties.compareGroup - 1;
            var query = $('#geoForm').find('input[name=compare]').eq(compareIndex).val();
        } else {
            var query = $('#geoForm').find('input[name=compare]').val();
        }
        
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
            //display a link to update the ajaxList
            if (feature.properties.type == 'mint') {
                var href = '?query=' + query + '; nmo:hasMint ' + feature.properties.gazetteer_uri.replace("http://nomisma.org/id/", "nm:");
                str += '<br/><a href="' + href + '" class="updateMap">View</a> results from this mint.';
            }
        }
        layer.bindPopup(str);
    }
}