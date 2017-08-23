$(document).ready(function () {
    
    initialize_map();
});

function initialize_map() {
    var query = $('#query').text();
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
    
    var map = new L.Map('mapcontainer', {
        center: new L.LatLng(0, 0),
        zoom: 4,
        layers:[awmcterrain]
    });
    
    //add overlay from AJAX
    var markers = L.markerClusterGroup();
    var overlay = L.geoJson.ajax('apis/query.json?query=' + query, {
        onEachFeature: onEachFeature,
        pointToLayer: renderPoints
    });
    
    //add controls
    var baseMaps = {
        "Ancient Terrain": awmcterrain,
        "Modern Terrain": terrain,
        "Modern Streets": osm,
        "Imperium": imperium
    };
    
    var overlayMaps = {
        'Features': overlay
    };
    
    L.control.layers(baseMaps, overlayMaps).addTo(map);
    
    //zoom to groups on AJAX complete
    overlay.on('data:loaded', function () {
        markers.addLayer(overlay);
        map.addLayer(markers);
        
        var group = new L.featureGroup([overlay]);
        map.fitBounds(group.getBounds());
    }.bind(this));
    
    
    /*****
     * Features for manipulating layers
     *****/
    function renderPoints(feature, latlng) {
        return new L.CircleMarker(latlng, {
            radius: 5,
            fillColor: '#6992fd',
            color: "#000",
            weight: 1,
            opacity: 1,
            fillOpacity: 0.6
        });
    }
    
    function onEachFeature (feature, layer) {
        if (feature.hasOwnProperty('id') == true) {
            str = '<a href="' + feature.id + '">' + feature.label + '</a><br/>';
        } else {
            str = feature.label;
        }
        layer.bindPopup(str);
    }
}