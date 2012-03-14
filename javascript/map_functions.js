function initialize_map(id) {
	map = new OpenLayers.Map('map', {
                    controls: [
                        new OpenLayers.Control.PanZoomBar(),
                        new OpenLayers.Control.Navigation(),
                        new OpenLayers.Control.ScaleLine()
                    ]
	});
	//map.addLayer(new OpenLayers.Layer.Google("Google Physical", {type: google.maps.MapTypeId.TERRAIN}));
	map.addLayer(new OpenLayers.Layer.WMS( "OpenLayers WMS", "http://vmap0.tiles.osgeo.org/wms/vmap0", {layers: 'basic'} ));
	var kmlLayer = new OpenLayers.Layer.Vector("KML", {
	 	eventListeners: {'loadend': kmlLoaded },
		strategies: [new OpenLayers.Strategy.Fixed()],
		protocol: new OpenLayers.Protocol.HTTP({
	               url: id + '-all.kml',
	                format: new OpenLayers.Format.KML({
	                    extractStyles: true, 
	                    extractAttributes: true
	                })
	            })
	});
	map.addLayer(kmlLayer);

	function kmlLoaded(){
		map.zoomToExtent(kmlLayer.getDataExtent());
		map.zoomTo('4');
	}
}
	
	/*selectControl = new OpenLayers.Control.SelectFeature(
                [kmlLayer],
                {
                    clickout: true, 
                    multiple: false, 
                    hover: false
                }
            );
	
	map.addControl(selectControl);
	selectControl.activate();
	kmlLayer.events.on({"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect});*/
     
	/*function onPopupClose(evt) {		
		map.removePopup(map.popups[0]);
	}
	
	function onFeatureSelect(event) {
		
	}
	
	function onFeatureUnselect(event) {
		map.removePopup(map.popups[0]);
	}     */

