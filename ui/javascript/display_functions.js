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
	$('#add-filter').click(function () {
		var type = $('#type').text();
		if (type.indexOf('foaf') >= 0) {
			type = 'foaf:Person|foaf:Organization';
		}
		$('#field-template').clone().removeAttr('id').appendTo('#filter-container');
		//work on removing the option for the current class
		$('#filter-container').find('option[type="' + type + '"]').remove();
		validate();
		return false;
	});
	
	//observe changes in drop down menus for validation
	$('#categorySelect').change(function () {
		validate();
	});
	
	//monitor changes from quantitative analysis drop down menus to execute ajax calls
	$(' #filter-container').on('change', '.filter .add-filter-prop', function () {
		var prop = $(this).val();
		var type = $(this).children('option:selected').attr('type');
		var next = $(this).next('.prop-container');
		
		getFacets(mode = 'filter', prop, type, next, path);
	});
	
	$(' #filter-container').on('change', '.filter .prop-container .add-filter-object', function () {
		validate();
	});
	
	//delete the compare/filter query pair
	$(' #filter-container').on('click', '.filter .control-container .remove-query', function () {
		$(this).closest('.filter').remove();
		validate();
		return false;
	});
	
	//on page load, populate the SPARQL-based query filters
	$('#calculateForm').find('.filter').each(function () {
		var prop = $(this).children('.add-filter-prop').val();
		var type = $(this).children('.add-filter-prop').children('option:selected').attr('type');
		var next = $(this).children('.add-filter-prop').next('.prop-container');
		var mode = $(this).parent('div').attr('class') == 'compare-container' ? 'compare': 'filter';
		
		getFacets(mode, prop, type, next, path);
	});
	
	/***COMPARE***/
	//add dataset for comparison
	$('#add-compare').click(function () {
		$('#compare-container-template').clone().removeAttr('id').appendTo('#compare-master-container');
		
		//automatically insert a property-object query pair
		$('#field-template').clone().removeAttr('id').appendTo('#compare-master-container .compare-container:last');
		validate();
		return false;
	});
	//add property-object facet into dataset
	$('#compare-master-container').on('click', 'h4 small .add-compare-field', function () {
		$('#field-template').clone().removeAttr('id').appendTo($(this).closest('.compare-container'));
		validate();
	
		var count = $(this).closest('.compare-container').children('.filter').length;

		//toggle the alert box when there aren't any filters
		if (count > 0){
			$(this).closest('.compare-container').children('.alert-box').addClass('hidden');
		} else {
			$(this).closest('.compare-container').children('.alert-box').removeClass('hidden');
		}
		
		return false;
	});
	
	//get facets on property drop-down list change
	$(' #compare-master-container').on('change', '.compare-container .filter .add-filter-prop', function () {
		var prop = $(this).val();
		var type = $(this).children('option:selected').attr('type');
		var next = $(this).next('.prop-container');
		
		getFacets(mode = 'compare', prop, type, next, path);
	});
	
	//validate on object drop-down list change
	$(' #compare-master-container').on('change', '.compare-container .filter .prop-container .add-filter-object', function () {
		validate();
	});
	
	//delete dataset query
	$(' #compare-master-container').on('click', '.compare-container h4 small .remove-dataset', function () {
		$(this).closest('.compare-container').remove();
		validate();
		return false;
	});
	
	//delete property-object pair
	$(' #compare-master-container').on('click', '.compare-container .filter .control-container .remove-query', function () {
		var count = $(this).closest('.compare-container').children('.filter').length;

		//toggle the alert box when there aren't any filters
		if (count == 1){
			$(this).closest('.compare-container').children('.alert-box').removeClass('hidden');
		} else {
			$(this).closest('.compare-container').children('.alert-box').addClass('hidden');
		}
		
		$(this).closest('.filter').remove();
		validate();
		
		
		return false;
	});
});

function getFacets(mode, prop, type, next, path) {
	if (type != null) {
		//define ajax parameters
		params = {
			"facet": prop
		}
		
		//add filter if we are filtering against the current Nomisma ID
		if (mode == 'filter') {
			params.filter = $('#base-query').text();
		}
		
		//add query, if available (prepopulating facet drop down menus)
		if (next.children('span').text().length > 0) {
			params.query = next.children('span').text();
		}
		
		//set ajax loader
		loader = $('#ajax-loader-template').clone().removeAttr('id');
		next.html(loader);
		
		$.get(path + 'ajax/getSparqlFacets', params,
		function (data) {
			next.html(data);
			validate();
		});
	} else {
		next.children('.add-filter-object').remove();
		validate();
	}
}

function validate() {
	var valid = false;
	
	if ($('#categorySelect').length > 0) {
		if ($('#categorySelect').val()) {
			valid = true;
			//iterate through additional filters
			$('#filter-container .filter').each(function () {
				if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
					//iterate through compared queries
					valid = true;
					
					//iterate through compare-containers, be sure there is at least one filter
					$('#compare-master-container .compare-container').each(function () {
						if ($(this).children('.filter').length > 0) {
							$(this).children('.filter').each(function () {
								if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
									valid = true;
								} else {
									valid = false;
								}
							});
						} else {
							valid = false;
						}
					});
				} else {
					valid = false;
				}
			});
			//if there are not filters, then iterate through compare queries
			if ($('#filter-container .filter').length <= 0) {
				//iterate through compare-containers, be sure there is at least one filter
				$('#compare-master-container .compare-container').each(function () {
					if ($(this).children('.filter').length > 0) {
						$(this).children('.filter').each(function () {
							if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
								valid = true;
							} else {
								valid = false;
							}
						});
					} else {
						valid = false;
					}
				});
			}
		}
	}
	
	//enable/disable button
	if (valid == true) {
		$('#visualize-submit').prop("disabled", false);
		
		//generate the filter query and assign the value to the hidden input
		q = generateFilter();
		$('input[name=filter]').val(q);
		
		//for each comparison query, insert an input, but clear input[name=compare] first
		$('input[name=compare]').remove();
		$('#compare-master-container .compare-container').each(function () {
			var formId = $(this).closest('form').attr('id');
			var q = new Array();
			$(this).children('.filter').each(function () {
				if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
					q.push($(this).children('.add-filter-prop').val() + ' ' + $(this).children('.prop-container').children('.add-filter-object').val());
				}
			});
			query = q.join('; ');
			$('#' + formId).append('<input name="compare" type="hidden" value="' + query + '">');
		});
	} else {
		$('#visualize-submit').prop("disabled", true);
	}
}

function generateFilter() {
	var q = new Array($('#base-query').text());
	
	//iterate through additional features
	$('#filter-container .filter').each(function () {
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