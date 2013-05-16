$(document).ready(function () {
	var id = $('title').attr('id');
	$('a.thumbImage').fancybox();
	initialize_map(id);
});

function initialize_map(id) {
	
	map = new OpenLayers.Map('mapcontainer', {
		controls:[
		new OpenLayers.Control.PanZoomBar(),
		new OpenLayers.Control.Navigation(),
		new OpenLayers.Control.ScaleLine(),
		new OpenLayers.Control.LayerSwitcher({
			'ascending': true
		})]
	});
	
	map.addLayer(new OpenLayers.Layer.OSM());
	
	/*map.addLayer(new OpenLayers.Layer.Google(
	"Google Physical", {
		type: google.maps.MapTypeId.TERRAIN
	}));*/
	
	//google physical
	var imperium = new OpenLayers.Layer.XYZ(
	"Imperium Romanum",[
	"http://pelagios.dme.ait.ac.at/tilesets/imperium/${z}/${x}/${y}.png"], {
		sphericalMercator: true,
		isBaseLayer: true,
		numZoomLevels: 12
	});
	
	map.addLayer(imperium);
	
	//point for coin or hoard KML
	var kmlLayer = new OpenLayers.Layer.Vector('KML', {
		eventListeners: {
			'loadend': kmlLoaded
		},
		strategies:[
		new OpenLayers.Strategy.Fixed()],
		protocol: new OpenLayers.Protocol.HTTP({
			url: id + '.kml',
			format: new OpenLayers.Format.KML({
				extractStyles: true,
				extractAttributes: true
			})
		})
	});
	
	//add origin point last
	map.addLayer(kmlLayer);
	
	function kmlLoaded() {
		map.zoomToExtent(kmlLayer.getDataExtent());
		map.zoomTo('4');
	}
	
	/*************** OBJECT KML FEATURES ******************/
	objectControl = new OpenLayers.Control.SelectFeature([kmlLayer], {
		clickout: true,
		//toggle: true,
		multiple: false,
		hover: false,
		//toggleKey: "ctrlKey",
		//multipleKey: "shiftKey"
	});
	
	map.addControl(objectControl);
	objectControl.activate();
	kmlLayer.events.on({
		"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect
	});
	
	function onFeatureSelect(event) {
		var feature = event.feature;
		message = '<div style="font-size:12px">' + feature.attributes.name + '</div>';
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
	}
	
	function onPopupClose(event) {
		map.removePopup(map.popups[0]);
	}
	
	
	function onFeatureUnselect(event) {
		map.removePopup(map.popups[0]);
	}
}