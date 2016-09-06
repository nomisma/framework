/*******
DISPLAY FUNCTIONS
Modified: August 2016
Function: These are javascript functions responsible for minor features on the HTML page for IDs,
e.g., showing and hiding SPARQL query divs
 *******/

$(document).ready(function () {
	var path = '../';
	var dist = getParameterByName('dist');
	var filter = getParameterByName('filter');
	
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
	if (dist != null && filter != null) {
		renderChart(path, dist, filter);
	}
});

function renderChart(path, dist, filter) {
	var distLabel = $('select[name=dist] option:selected').text().toLowerCase();
	
	$.get(path + 'apis/getCount', {
		filter: filter, dist: dist
	},
	function (data) {
		$('#chart').height(600);
		var visualization = d3plus.viz().container("#chart").data(data).type("bar").id('subset').x(distLabel).y("count").draw();
	});
}


//get URL parameters, from http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
function getParameterByName(name, url) {
	if (! url) url = window.location.href;
	name = name.replace(/[\[\]]/g, "\\$&");
	var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
	results = regex.exec(url);
	if (! results) return null;
	if (! results[2]) return '';
	return decodeURIComponent(results[2].replace(/\+/g, " "));
}