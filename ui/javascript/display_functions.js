/*******
DISPLAY FUNCTIONS
Modified: March 2015
Function: These are javascript functions responsible for minor features on the HTML page for IDs,
e.g., showing and hiding SPARQL query divs
*******/

$(document).ready(function(){
	$('.toggle-button').click(function(){
		var div = $(this).attr('id').split('-')[1];
		$('#' + div).toggle();
		
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
});
