function initialize_map(q) {
	map = new OpenLayers.Map('indexMap', {
                    controls: [
                        new OpenLayers.Control.PanZoomBar(),
                        new OpenLayers.Control.Navigation(),
                        new OpenLayers.Control.ScaleLine(),
                    ]
	});
	
               var styleMap = new OpenLayers.Style({
                    pointRadius: "5",
                    fillColor: "#5757a6",
                    fillOpacity: 0.6,
                    strokeColor: "#505080",
                    strokeWidth: 1,
                    strokeOpacity: 0.6
                });
                
	map.addLayer(new OpenLayers.Layer.Google("Google Physical", {type: google.maps.MapTypeId.TERRAIN}));
	var kmlLayer = new OpenLayers.Layer.Vector("KML", {
	 	styleMap: styleMap,
	 	eventListeners: {'loadend': kmlLoaded },
		strategies: [
				new OpenLayers.Strategy.Fixed(),
				//new OpenLayers.Strategy.Cluster()
			],
		protocol: new OpenLayers.Protocol.HTTP({
	                url: "query.kml?q=" + q,
	                format: new OpenLayers.Format.KML({
	                    extractStyles: false, 
	                    extractAttributes: true
	                })
	            })
	});
	map.addLayer(kmlLayer);

	function kmlLoaded(){
		map.zoomToExtent(kmlLayer.getDataExtent());
		map.zoomTo('2');
	}
	
	selectControl = new OpenLayers.Control.SelectFeature(
                [kmlLayer],
                {
                    clickout: true, 
                    //toggle: true,
                    multiple: false, 
                    hover: false,
                    //toggleKey: "ctrlKey",
                    //multipleKey: "shiftKey"
                }
            );
	
	map.addControl(selectControl);
	selectControl.activate();
	kmlLayer.events.on({"featureselected": onFeatureSelect, "featureunselected": onFeatureUnselect});
     
	function onPopupClose(evt) {		
		map.removePopup(map.popups[0]);
	}
	
	function onFeatureSelect(event) {
		var message = '';
		message =  '<div style="font-size:10px"><a href="' + event.feature.attributes['description'] + '" target="_blank">'  + event.feature.attributes['name'] +  '</a></div>';		
		popup = new OpenLayers.Popup.FramedCloud("id", event.feature.geometry.bounds.getCenterLonLat(), null, message, null, true, onPopupClose);
		event.popup = popup;
		map.addPopup(popup);
	}
	
	function onFeatureUnselect(event) {
		map.removePopup(map.popups[0]);
	}     

}
