$(document).ready(function () {
    
    initialize_map();
});

function initialize_map() {
    var query = $('#query').text();
    var mapboxKey = $('#mapboxKey').text();
    
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
    
    //add overlay from AJAX
    var markers = L.markerClusterGroup();
    var overlay = L.geoJson.ajax('apis/query.json?query=' + query, {
        onEachFeature: onEachFeature,
        pointToLayer: renderPoints
    });
    
    //add controls
	var baseMaps = {
	   "Terrain and Streets": mb_physical,
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