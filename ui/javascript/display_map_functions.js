$(document).ready(function () {
	var id = $('title').attr('id');
	
	$('.toggle-geoJSON').click(function () {
		$('#geoJSON-fragment').toggle();
		$('#geoJSON-full').toggle();
		return false;
	});
	
	initialize_map(id);
});

function initialize_map(id) {
	var prefLabel = $('span[property="skos:prefLabel"]:lang(en)').text();
	var type = $('#type').text();
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
	
	var map = new L.Map('mapcontainer', {
		center: new L.LatLng(0, 0),
		zoom: 4,
		layers:[awmcterrain, heatmapLayer]
	});
	
	//add mintLayer from AJAX
	var mintLayer = L.geoJson.ajax('../apis/getMints?id=' + id, {
		onEachFeature: function (feature, layer) {
			var str;
			if (feature.properties.hasOwnProperty('uri') == false) {
				str = feature.properties.name;
			} else {
				str = '<a href="' + feature.properties.uri + '">' + feature.properties.name + '</a>';
			}
			layer.bindPopup(str);
		},
		pointToLayer: function (feature, latlng) {
			return new L.CircleMarker(latlng, {
				radius: 5,
				fillColor: "#6992fd",
				color: "#000",
				weight: 1,
				opacity: 1,
				fillOpacity: 0.6
			});
		}
	}).addTo(map);
	
	//add findspot layer, but don't make visible
	var findspotLayer = L.geoJson.ajax('../apis/getFindspots?id=' + id, {
		onEachFeature: function (feature, layer) {
			var str;
			if (feature.properties.hasOwnProperty('uri') == false) {
				str = feature.properties.name;
			} else {
				str = '<a href="' + feature.properties.uri + '">' + feature.properties.name + '</a>';
			}
			layer.bindPopup(str);
		},
		pointToLayer: function (feature, latlng) {
			return new L.CircleMarker(latlng, {
				radius: 5,
				fillColor: "#d86458",
				color: "#000",
				weight: 1,
				opacity: 1,
				fillOpacity: 0.6
			});
		}
	});
	
	//load heatmapLayer after JSON loading concludes
	$.getJSON('../apis/heatmap?id=' + id, function (data) {
		heatmapLayer.setData(data);
	});
	
	//add controls
	var baseMaps = {
		"Ancient Terrain": awmcterrain,
		"Modern Terrain": terrain,
		"Modern Streets": osm,
		"Imperium": imperium
	};
	
	var overlayMaps = {
	};
	
	//add baselayers
	if (type == 'nmo:Mint' || type == 'nmo:Region') {
		overlayMaps[prefLabel] = mintLayer;
	} else {
		overlayMaps[ 'Mints'] = mintLayer;
	}
	
	if (type == 'nmo:Hoard') {
		overlayMaps[prefLabel] = findspotLayer;
		findspotLayer.addTo(map);
	} else {
		overlayMaps[ 'Findspots'] = findspotLayer;
		overlayMaps[ 'Heatmap'] = heatmapLayer;
	}
	
	L.control.layers(baseMaps, overlayMaps).addTo(map);
	
	//zoom to groups on AJAX complete
	mintLayer.on('data:loaded', function () {
		var group = new L.featureGroup([findspotLayer, mintLayer]);
		map.fitBounds(group.getBounds());
	}.bind(this));
	
	findspotLayer.on('data:loaded', function () {
		var group = new L.featureGroup([findspotLayer, mintLayer]);
		map.fitBounds(group.getBounds());
	}.bind(this));
}