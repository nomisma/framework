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
    var path = $('#path').text();
    var url = path + id + ".geojson";
    
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
        //layers:[awmcterrain, heatmapLayer]
        layers:[mb_physical]
    });
    
    //add controls
    var baseMaps = {
        "Terrain and Streets": mb_physical,
        "Modern Streets": osm,
        "Imperium": imperium
    };
    
    //add controls
    var layerControl = L.control.layers(baseMaps).addTo(map);
    
    //add GeoJSON from AJAX
    $.getJSON(url, function (data) {
        var maxFindspotDensity = 0;
        var maxMintDensity = 0;
        
        //split features into separate objects
        var mints = {
            "type": "FeatureCollection",
            "features":[]
        };
        var hoards = {
            "type": "FeatureCollection",
            "features":[]
        };
        var findspots = {
            "type": "FeatureCollection",
            "features":[]
        };
        
        $.each(data.features, function (key, value) {
            if (value.properties.type == 'findspot' && value.properties.hasOwnProperty('count') == true) {
                if (value.properties.count !== undefined) {
                    if (value.properties.count > maxFindspotDensity) {
                        maxFindspotDensity = value.properties.count;
                    }
                }
            } else if (value.properties.type == 'mint' && value.properties.hasOwnProperty('count') == true) {
                if (value.properties.count !== undefined) {
                    if (value.properties.count > maxMintDensity) {
                        maxMintDensity = value.properties.count;
                    }
                }
            }
            
            //populate objects
            if (value.properties.type == 'mint') {
                mints.features.push(value);
            }
            if (value.properties.type == 'hoard') {
                hoards.features.push(value);
            }
            if (value.properties.type == 'findspot') {
                findspots.features.push(value);
            }
        });
        
        //create overlays for the three types of features
        var mintLayer = L.geoJson(mints, {
            onEachFeature: onEachFeature,
            style: function (feature) {
                if (feature.geometry.type == 'Polygon') {
                    var fillColor = getFillColor(feature.properties.type);
                    
                    return {
                        color: fillColor
                    }
                }
            },
            pointToLayer: function (feature, latlng) {
                return renderPoints(feature, latlng, maxFindspotDensity, maxMintDensity);
            }
        }).addTo(map);
        
        var hoardLayer = L.geoJson(hoards, {
            onEachFeature: onEachFeature,
            style: function (feature) {
                if (feature.geometry.type == 'Polygon') {
                    var fillColor = getFillColor(feature.properties.type);
                    
                    return {
                        color: fillColor
                    }
                }
            },
            pointToLayer: function (feature, latlng) {
                return renderPoints(feature, latlng, maxFindspotDensity, maxMintDensity);
            }
        }).addTo(map);
        
        var findLayer = L.geoJson(findspots, {
            onEachFeature: onEachFeature,
            style: function (feature) {
                if (feature.geometry.type == 'Polygon') {
                    var fillColor = getFillColor(feature.properties.type);
                    
                    return {
                        color: fillColor
                    }
                }
            },
            pointToLayer: function (feature, latlng) {
                return renderPoints(feature, latlng, maxFindspotDensity, maxMintDensity);
            }
        }).addTo(map);
        
        //add layers to controls
        layerControl.addOverlay(mintLayer, 'Mints');
        layerControl.addOverlay(hoardLayer, 'Hoards');
        layerControl.addOverlay(findLayer, 'Finds');
        
        var group = new L.featureGroup([findLayer, mintLayer, hoardLayer]);
        map.fitBounds(group.getBounds());
    });
    
    
    
    /*****
     * Features for manipulating layers
     *****/
    function renderPoints(feature, latlng, maxFindspotDensity, maxMintDensity) {
        
        var fillColor = getFillColor(feature.properties.type);
        
        if (feature.properties.type == 'findspot' && feature.properties.hasOwnProperty('count')) {
            grade = maxFindspotDensity / 5;
            
            var radius = 5;
            if (Math.round(grade) == 0) {
                radius = 5;
            } else if (feature.properties.count < Math.round(grade)) {
                radius = 5;
            } else if (feature.properties.count >= Math.round(grade) && feature.properties.count < Math.round(grade * 2)) {
                radius = 10;
            } else if (feature.properties.count >= Math.round(grade * 2) && feature.properties.count < Math.round(grade * 3)) {
                radius = 15;
            } else if (feature.properties.count >= Math.round(grade * 3) && feature.properties.count < Math.round(grade * 4)) {
                radius = 20;
            } else if (feature.properties.count >= Math.round(grade * 4)) {
                radius = 25;
            } else {
                radius = 5;
            }
            
            return new L.CircleMarker(latlng, {
                radius: radius,
                fillColor: fillColor,
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.6
            });
        } else if (feature.properties.type == 'mint' && feature.properties.hasOwnProperty('count')) {
            grade = maxMintDensity / 5;
            
            var radius = 5;
            if (Math.round(grade) == 0) {
                radius = 5;
            } else if (feature.properties.count < Math.round(grade)) {
                radius = 5;
            } else if (feature.properties.count >= Math.round(grade) && feature.properties.count < Math.round(grade * 2)) {
                radius = 10;
            } else if (feature.properties.count >= Math.round(grade * 2) && feature.properties.count < Math.round(grade * 3)) {
                radius = 15;
            } else if (feature.properties.count >= Math.round(grade * 3) && feature.properties.count < Math.round(grade * 4)) {
                radius = 20;
            } else if (feature.properties.count >= Math.round(grade * 4)) {
                radius = 25;
            } else {
                radius = 5;
            }
            
            return new L.CircleMarker(latlng, {
                radius: radius,
                fillColor: fillColor,
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.6
            });
        } else {
            return new L.CircleMarker(latlng, {
                radius: 5,
                fillColor: fillColor,
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.6
            });
        }
    }
    
    function getFillColor (type) {
        var fillColor;
        switch (type) {
            case 'mint':
            fillColor = '#6992fd';
            break;
            case 'findspot':
            fillColor = '#f98f0c';
            break;
            case 'hoard':
            fillColor = '#d86458';
            break;
            default:
            fillColor = '#efefef'
        }
        
        return fillColor;
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
                str += '<a href="' + feature.properties.gazetteer_uri + '">' + feature.properties.toponym + '</a></span>';
                if (feature.properties.type == 'hoard' && feature.properties.hasOwnProperty('closing_date') == true) {
                    str += '<br/><b>Closing Date: </b>' + feature.properties.closing_date;
                }
            }
            if (feature.properties.hasOwnProperty('count') == true) {
                str += '<br/><b>Count: </b>' + feature.properties.count;
            }
        }
        layer.bindPopup(str);
    }
}