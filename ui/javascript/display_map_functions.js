$(document).ready(function () {
    var id = $('title').attr('id');
    //$('a.thumbImage').fancybox();
    
    $('.toggle-geoJSON').click(function () {
        $('#geoJSON-fragment').toggle();
        $('#geoJSON-full').toggle();
        return false;
    });
    
    initialize_map(id);
});

function initialize_map(id) {    
    var kmlUrl = id + '.kml';
    
    var osm = L.tileLayer(
    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'OpenStreetMap',
        maxZoom: 18
    });
    
    var imperium = L.tileLayer(
    'http://dare.ht.lu.se/tiles/imperium/{z}/{x}/{y}.png', {
        maxZoom: 12,
        attribution: ''
    });
    
    var heatmapLayer = new HeatmapOverlay({
        "radius": .5,
        "maxOpacity": .8,
        "scaleRadius": true,
        "useLocalExtrema": true,
        latField: 'lat',
        lngField: 'lng',
        valueField: 'count'
    });
    
    var kml = omnivore.kml(kmlUrl)
    
    var map = new L.Map('mapcontainer', {
        center: new L.LatLng(0, 0),
        zoom: 6,
        layers:[osm, heatmapLayer]
    });
    
    //add primary layer (mint or region)
    if ($('span[property="geo:lat"]').length > 0 && $('span[property="geo:long"]').length > 0) {
        var lat = $('span[property="geo:lat"]').text();
        var lon = $('span[property="geo:long"]').text();
        L.marker([lat, lon]).addTo(map).bindPopup($('span[property="skos:prefLabel"]:lang(en)').text());
        map.panTo([lat, lon]);
    } else if ($('span[property="osgeo:asGeoJSON"]').length > 0) {
        var geoJsonString = $('span[property="osgeo:asGeoJSON"]').text();
        var polygon = jQuery.parseJSON(geoJsonString);
        L.geoJson(polygon, {
            onEachFeature: function (feature, layer) {
                var bounds = layer.getBounds();
                // Get center of bounds
                var center = bounds.getCenter();
                map.panTo(center);
            }
        }).addTo(map).bindPopup($('span[property="skos:prefLabel"]:lang(en)').text());
    }
    
    
    var baseMaps = {
        "Open Street Map": osm,
        "Imperium": imperium
    };
    
    var overlayMaps = {
        "Heatmap": heatmapLayer,
        "KML": kml
    };
    
    L.control.layers(baseMaps, overlayMaps).addTo(map);
    
    $.getJSON('../apis/heatmap?uri=http://nomisma.org/id/' + id, function (data) {
        heatmapLayer.setData(data);
        var bounds = heatmapLayer.getBounds();
    });
    
    
    
    
    
    /*  var runLayer = omnivore.kml(kmlUrl).on('ready', function () {
    map.fitBounds(runLayer.getBounds());
    }).addTo(map);*/
}