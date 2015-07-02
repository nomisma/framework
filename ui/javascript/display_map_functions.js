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
    var prefLabel = $('span[property="skos:prefLabel"]:lang(en)').text();
    var kmlUrl = id + '.kml';
    var mapboxKey = $('#mapboxKey').text();
    
    //baselayers
    var awmcterrain = L.tileLayer(
    'https://api.tiles.mapbox.com/v4/isawnyu.map-knmctlkh/{z}/{x}/{y}.png?access_token=' + mapboxKey, {
        attribution: 'Powered by <a href="http://leafletjs.com/">Leaflet</a> and <a href="https://www.mapbox.com/">Mapbox</a>. Map base by <a title="Ancient World Mapping Center (UNC-CH)" href="http://awmc.unc.edu">AWMC</a>, 2014 (cc-by-nc).',
        maxZoom: 12
    });
    
    /* Not added by default, only through user control action */
    var terrain = L.tileLayer(
    'https://api.tiles.mapbox.com/v4/isawnyu.map-p75u7mnj/{z}/{x}/{y}.png?access_token=' + mapboxKey, {
        attribution: 'Powered by <a href="http://leafletjs.com/">Leaflet</a> and <a href="https://www.mapbox.com/">Mapbox</a>. Map base by <a title="Institute for the Study of the Ancient World (ISAW)" href="http://isaw.nyu.edu">ISAW</a>, 2014 (cc-by).'
    });
    
    var osm = L.tileLayer(
    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'OpenStreetMap',
        maxZoom: 18
    });
    
    var imperium = L.tileLayer(
    'http://dare.ht.lu.se/tiles/imperium/{z}/{x}/{y}.png', {
        maxZoom: 12,
        attribution: 'Powered by <a href="http://leafletjs.com/">Leaflet</a>. Map base: <a href="http://dare.ht.lu.se/" title="Digital Atlas of the Roman Empire, Department of Archaeology and Ancient History, Lund University, Sweden">DARE</a>, 2015 (cc-by-sa).'
    });
    
    //overlays
    var heatmapLayer = new HeatmapOverlay({
        "radius": .5,
        "maxOpacity": .8,
        "scaleRadius": true,
        "useLocalExtrema": true,
        latField: 'lat',
        lngField: 'lng',
        valueField: 'count'
    });
    
    var kmlLayer = new L.KML(kmlUrl, {
        async: true
    });
    
    var map = new L.Map('mapcontainer', {
        center: new L.LatLng(0, 0),
        zoom: 4,
        layers:[awmcterrain, heatmapLayer]
    });
    
    //add primary layer (mint or region)
    if ($('span[property="geo:lat"]').length > 0 && $('span[property="geo:long"]').length > 0) {
        var lat = $('span[property="geo:lat"]').text();
        var lon = $('span[property="geo:long"]').text();
        var primaryLayer = L.marker([lat, lon]);
        primaryLayer.addTo(map).bindPopup(prefLabel);
    } else if ($('span[property="osgeo:asGeoJSON"]').length > 0) {
        var geoJsonString = $('span[property="osgeo:asGeoJSON"]').text();
        var polygon = jQuery.parseJSON(geoJsonString);
        var primaryLayer = L.geoJson(polygon);
        primaryLayer.addTo(map).bindPopup(prefLabel);
    } else {
        var primaryLayer = 'null';
    }
    
    //add controls
    var baseMaps = {
        "Ancient Terrain": awmcterrain,
        "Modern Terrain": terrain,
        "Modern Streets": osm,
        "Imperium": imperium
    };
    
    var overlayMaps = {
        "Heatmap": heatmapLayer,
        "KML": kmlLayer
    };
    if (primaryLayer != 'null') {
        overlayMaps[prefLabel] = primaryLayer;
    }
    
    L.control.layers(baseMaps, overlayMaps).addTo(map);
    
    //load heatmapLayer after JSON loading concludes
    $.getJSON('../apis/heatmap?uri=http://nomisma.org/id/' + id, function (data) {
        heatmapLayer.setData(data);
        var bounds = heatmapLayer.getBounds();
        map.fitBounds(bounds);
    });
    
    //the KML includes the full geographic extent, so fit bounds when ready
    kmlLayer.on('loaded', function () {
        map.fitBounds(kmlLayer.getBounds());
    });
}