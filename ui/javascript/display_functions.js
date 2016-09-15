/*******
DISPLAY FUNCTIONS
Modified: August 2016
Function: These are javascript functions responsible for minor features on the HTML page for IDs,
e.g., showing and hiding SPARQL query divs
 *******/

$(document).ready(function () {
	//get URL parameters, from http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
	var urlParams;
	(window.onpopstate = function () {
		var match,
		pl = /\+/g, // Regex for replacing addition symbol with a space
		search = /([^&=]+)=?([^&]*)/g,
		decode = function (s) {
			return decodeURIComponent(s.replace(pl, " "));
		},
		query = window.location.search.substring(1);
		
		urlParams = {
		};
		compare = new Array();
		while (match = search.exec(query)) {
			if (decode(match[1]) == 'compare') {
				if (decode(match[2]).length > 0){
					compare.push(decode(match[2]));
				}				
			} else {
				urlParams[decode(match[1])] = decode(match[2]);
			}
		}
		urlParams['compare'] = compare;
	})();
	
	var path = '../';
	
	$('.page-section').on('click', '.control-row .toggle-button', function () {
		var div = $(this).attr('id').split('-')[1];
		$('#' + div + '-div').toggle();
		
		//replace minus with plus and vice versa
		var span = $(this).children('span');
		if (span.attr('class').indexOf('minus') > 0) {
			span.removeClass('glyphicon-minus');
			span.addClass('glyphicon-plus');
		} else {
			span.removeClass('glyphicon-plus');
			span.addClass('glyphicon-minus');
		}
		return false;
	});
	
	//if there is a div with a id=listTypes, then initiate ajax call
	if ($('#listTypes').length > 0) {
		var id = $('title').attr('id');
		var type = $('#type').text();
		
		$.get(path + 'ajax/listTypes', {
			id: id, type: type
		},
		function (data) {
			$('#listTypes').html(data);
		});
	}
	
	$('a.thumbImage').fancybox({
		type: 'image',
		beforeShow: function () {
			this.title = '<a href="' + this.element.attr('id') + '">' + this.element.attr('title') + '</a>'
		},
		helpers: {
			title: {
				type: 'inside'
			}
		}
	});
	
	//render chart if parameters are provided
	if (urlParams['dist'] != null && urlParams['filter'] != null) {
		renderChart(path,urlParams);
	}
});

function renderChart(path, urlParams) {
	var distLabel = $('select[name=dist] option:selected').text().toLowerCase();
	var y = 'percentage';
	if (urlParams['type'] == 'count') {
		var y = 'count';
	}
	
	$.get(path + 'apis/getCount', $.param(urlParams, true),
	function (data) {
		$('#chart').height(600);
		var visualization = d3plus.viz().container("#chart").data(data).type("bar").id('subset').x(distLabel).y(y).draw();
	});
}