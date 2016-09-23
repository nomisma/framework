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
				if (decode(match[2]).length > 0) {
					compare.push(decode(match[2]));
				}
			} else {
				urlParams[decode(match[1])] = decode(match[2]);
			}
		}
		urlParams[ 'compare'] = compare;
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
	if (urlParams[ 'dist'] != null && urlParams[ 'filter'] != null) {
		renderChart(path, urlParams);
	}
	
	//when clicking the add-filter link, insert a new filter template into the filter container
	$('#add-filter').click(function(){
		$('#filter-template').clone().appendTo('#filter-container');
		$('#filter-container').children('.form-group').removeAttr('id');
		validate();
		return false;
	});
	
	//observe changes in drop down menus for validation
	$('#categorySelect').change(function() {
		validate();	
	});
	
	//monitor changes from quantitative analysis drop down menus to execute ajax calls
	$(' #filter-container') .on('change', '.filter .add-filter-prop', function () {
		validate();
		var prop = $(this).val();
		var type = $(this).children('option:selected').attr('type');
		var next = $(this).next('.prop-container');
		
		if (type != null) {
			//set ajax loader
			loader = $('#ajax-loader-template').clone().removeAttr('id');
			next.html(loader);
			//next.children('span').removeAttr('id');
		
			var filter = $('#base-query').text();
			$.get(path + 'ajax/getSparqlFacets', {
				filter: filter, facet: prop
			},
			function (data) {
				next.html(data);
			});
		} else {
			next.children('.add-filter-object').remove();
		}
	});
	
	$(' #filter-container') .on('change', '.filter .prop-container .add-filter-object', function () {
		validate();
	});
	
	//delete the compare/filter query pair
	$(' #filter-container') .on('click', '.filter .control-container .remove-query', function () {
		$(this).closest('.filter').remove();
		validate();
		return false;
	});
});

function validate() {
	var valid = false;
	
	if ($('#categorySelect').length > 0) {
		if ($('#categorySelect').val()) {
			valid = true;
			$('#filter-container .filter').each(function(){
				if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
					valid = true;
				} else {
					valid = false;
				}
			});
		}
	}
	
	//enable/disable button
	if (valid == true) {
		$('#visualize-submit').prop("disabled", false);
		
		//generate the filter query and assign the value to the hidden input
		q = generateFilter();
		$('input[name=filter]').val(q);
	} else {
		$('#visualize-submit').prop("disabled", true);
	}
}

function generateFilter(){
	var q = new Array($('#base-query').text());
	
	//iterate through additional features
	$('#filter-container .filter').each(function(){
		if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
			q.push($(this).children('.add-filter-prop').val() + ' ' + $(this).children('.prop-container').children('.add-filter-object').val());
		}
	});
	
	query = q.join('; ');
	
	return query;
}

function renderChart(path, urlParams) {
	var distLabel = $('select[name=dist] option:selected').text().toLowerCase();
	var y = 'percentage';
	if (urlParams[ 'type'] == 'count') {
		var y = 'count';
	}
	
	$.get(path + 'apis/getCount', $.param(urlParams, true),
	function (data) {
		$('#chart').height(600);
		var visualization = d3plus.viz().container("#chart").data(data).type("bar").id('subset').x(distLabel).y(y).legend({
			"value": true, "size": 50
		}).color({
			"value": "subset"
		}).draw();
	});
}