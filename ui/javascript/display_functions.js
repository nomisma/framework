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
		var span = $(this).child('span');
		if (span.attr('class').indexOf('minus') > 0) {
			span.removeClass('glyphicon-minus');
			span.addClass('glyphicon-plus');
			$('#' + list).hide();
		} else {
			span.removeClass('glyphicon-plus');
			span.addClass('glyphicon-minus');
		}
		return false;
	});
});
