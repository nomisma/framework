var map, vectors;

function init() {
	//first clear map
	$('#map').html('');
	
	//establish projections
	var epsg4326 = new OpenLayers.Projection('EPSG:4326');
	var epsg900913 = new OpenLayers.Projection('EPSG:900913');
	
	map = new OpenLayers.Map('map', {
		projection: epsg4326
	});
	vectors = new OpenLayers.Layer.Vector('canvas', {
		projection: epsg4326
	});
	vectors.events.on({
		featuremodified: modify
	});
	var terrain = new OpenLayers.Layer.Google(
	"Google Physical", {
		type: google.maps.MapTypeId.TERRAIN
	});
	map.addLayers([terrain, vectors]);
	
	//add draw controls
	var controls = {
		point: new OpenLayers.Control.DrawFeature(vectors,
		OpenLayers.Handler.Point, {
			featureAdded: create
		}),
		polygon: new OpenLayers.Control.DrawFeature(vectors,
		OpenLayers.Handler.Polygon, {
			featureAdded: create
		}),
		modify: new OpenLayers.Control.ModifyFeature(vectors)
	};
	for (var key in controls) {
		map.addControl(controls[key]);
	}
	
	var hasFeature = ORBEON.xforms.Document.getValue("geo-hasFeature");
	
	//render existing point or polygon if there is already a feature
	if (hasFeature == 'true') {
		var lat = ORBEON.xforms.Document.getValue('geo-lat');
		var lon = ORBEON.xforms.Document.getValue('geo-long');
		var geoJSON = ORBEON.xforms.Document.getValue('geo-geoJSON');
		
		if (geoJSON.length > 0) {
			var geojson_format = new OpenLayers.Format.GeoJSON({
				'internalProjection': epsg900913,
				'externalProjection': epsg4326
			});
			vectors.addFeatures(geojson_format.read(geoJSON));
		} else {
			vectors.addFeatures(new OpenLayers.Feature.Vector(
			new OpenLayers.Geometry.Point(lon, lat).transform(epsg4326, epsg900913)));
		}
		
		map.zoomToExtent(vectors.getDataExtent());
		ORBEON.xforms.Document.setValue('geo-hasFeature', 'false');
		controls.modify.activate();
	} else {
		map.setCenter(new OpenLayers.LonLat(0, 0), 1);
		var type = ORBEON.xforms.Document.getValue('geo-type-control');
		
		if (type == 'point') {
			controls.point.activate();
			controls.polygon.deactivate();
		} else if (type == 'polygon') {
			controls.point.deactivate();
			controls.polygon.activate();
		}
	}
	
	/**** functions for processing geographic JSON into RDF ****/
	function create(feature) {
		serialize(feature);
	}
	
	function modify(event) {
		serialize(event.feature);
	}
	
	function serialize(feature) {
		if (vectors.features.length > 0) {
			//deactive draw controls
			controls.point.deactivate();
			controls.polygon.deactivate();
			//activate modify
			controls.modify.activate();
		} else {
			controls.modify.deactivate();
		}
		
		var str = new OpenLayers.Format.GeoJSON({
			'internalProjection': map.baseLayer.projection,
			'externalProjection': epsg4326
		}).write(feature.geometry);
		
		//reparse geoJSON for processing
		obj = JSON.parse(str);
		
		if (obj.type == 'Point') {
			ORBEON.xforms.Document.setValue('lat-input', obj.coordinates[1]);
			ORBEON.xforms.Document.setValue('long-input', obj.coordinates[0]);
		} else {
			ORBEON.xforms.Document.setValue('geoJSON-input', str);
		}
	}
}