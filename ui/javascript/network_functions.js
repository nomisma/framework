/*******
FORCED NETWORK GRAPH FUNCTIONS FOR D3PLUS
Modified: September 2024
Function: These are the functions for generating a forced network graph for die and type pages when a die study is actived.
 *******/
$(document).ready(function () {
    var path = '../';
    var urlParams = {
        'uri': $('#conceptURI').text(),
        'id': $('.network-graph').attr('id'),
        'level': 1
    };
    
    /**** RENDER CHART ****/
    renderNetworkGraph(path, urlParams);
    
    $('#render-graph').click(function(){
        urlParams['level'] = $('#graph-level').val();
        console.log(urlParams);
        $('#' + urlParams['id']).html('');        
        renderNetworkGraph(path, urlParams);
        
        return false;
    });
});

//initiate a call to the getDieLinks JSON API and parse the resulting object into a d3plus Network
function renderNetworkGraph(path, urlParams) {
    
    //alert(urlParams);
    $('#' + urlParams['id']).removeClass('hidden');
    $('#' + urlParams['id']).height(600);
    
    $.get(path + 'apis/getSymbolLinks', $.param(urlParams, true),
    function (data) {
        var nodeArray = data[ 'nodes'];
        var edgeArray = data[ 'edges'];
        
        const network = new d3plus.Network().config({
            links: edgeArray,
            linkSize: function (edge) {
                return edge.weight;
            },
            nodes: nodeArray,
            label: function (node) {
                if (node.hasOwnProperty('image')) {
                    return '';
                } else {
                    return node.label;
                }
            },
            tooltipConfig: {
                body: function (node) {
                    if (node.hasOwnProperty('image')) {
                        return '<div class="text-center"><strong>' + node.label + '</strong><br/><img src="' + node.image + '" style="width:32px"/></div>';
                    }
                }
            },
            shapeConfig: {
                backgroundImage: function (node) {
                    if (node.hasOwnProperty('image')) {
                        return node.image;
                    }
                }
            },
            color: function (node) {
                switch (node.side){
                    case 'obv':
                        return '#282f6b';
                        break;
                    case 'rev':
                        return '#b22200';
                        break;
                    case 'both':
                        return '#7e12cc';
                        break;
                    case 'first':
                        return '#6985c6';
                        break;
                    case 'second':
                        return '#b3c9fc';
                        break;
                    default:
                        return '#a8a8a8'
                }
            }
        }).on("click", function (node) {
            window.location.href = node.uri;
        }).select('#' + urlParams['id']).render();
    });
}