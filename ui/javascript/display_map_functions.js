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
	/*var heatmapLayer = new HeatmapOverlay({
		"radius": .5,
		"maxOpacity": .8,
		"scaleRadius": true,
		"useLocalExtrema": true,
		latField: 'lat',
		lngField: 'lng',
		valueField: 'count'
	});*/
	
	var map = new L.Map('mapcontainer', {
		center: new L.LatLng(0, 0),
		zoom: 4,
		//layers:[awmcterrain, heatmapLayer]
		layers:[awmcterrain]
	});
	
	//add mintLayer from AJAX
	var mintLayer = L.geoJson.ajax('../apis/getMints?id=' + id, {
		onEachFeature: onEachFeature,
		pointToLayer: renderPoints
	}).addTo(map);
	
	//add hoards, but don't make visible by default
	var hoardLayer = L.geoJson.ajax('../apis/getHoards?id=' + id, {
		onEachFeature: onEachFeature,
		pointToLayer: renderPoints
	}).addTo(map);
	
	//add individual finds layer, but don't make visible
	var findLayer = L.geoJson.ajax('../apis/getFindspots?id=' + id, {
		onEachFeature: onEachFeature,
		pointToLayer: renderPoints
	}).addTo(map);
	
	//load heatmapLayer after JSON loading concludes
/*	$.getJSON('../apis/heatmap?id=' + id, function (data) {
		heatmapLayer.setData(data);
	});*/
	
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
		overlayMaps['Mints'] = mintLayer;
	}
	
	if (type == 'nmo:Hoard') {
		overlayMaps[prefLabel] = hoardLayer;
		hoardLayer.addTo(map);
	} else {
		overlayMaps[ 'Hoards'] = hoardLayer;
		overlayMaps[ 'Finds'] = findLayer;
		//overlayMaps[ 'Heatmap'] = heatmapLayer;
	}
	
	L.control.layers(baseMaps, overlayMaps).addTo(map);
	
	//zoom to groups on AJAX complete
	mintLayer.on('data:loaded', function () {
		var group = new L.featureGroup([findLayer, mintLayer, hoardLayer]);
		map.fitBounds(group.getBounds());
	}.bind(this));
	
	hoardLayer.on('data:loaded', function () {
		var group = new L.featureGroup([findLayer, mintLayer, hoardLayer]);
		map.fitBounds(group.getBounds());
	}.bind(this));
	
	findLayer.on('data:loaded', function () {
		var group = new L.featureGroup([findLayer, mintLayer, hoardLayer]);
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
				str +='<a href="' + feature.properties.gazetteer_uri + '">' + feature.properties.toponym + '</a></span>'
			}
		}
		layer.bindPopup(str);
	}
}