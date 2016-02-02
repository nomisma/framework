/*******
DISPLAY FUNCTIONS
Modified: March 2015
Function: These are javascript functions responsible for minor features on the HTML page for IDs,
e.g., showing and hiding SPARQL query divs
*******/

$(document).ready(function(){
	$('.toggle-button').click(function () {
		var div_id = $(this).attr('id').split('-')[1] + '-div';
		if ($(this).children('span').hasClass('glyphicon-triangle-bottom')) {
			$(this).children('span').removeClass('glyphicon-triangle-bottom');
			$(this).children('span').addClass('glyphicon-triangle-right');
		} else {
			$(this).children('span').removeClass('glyphicon-triangle-right');
			$(this).children('span').addClass('glyphicon-triangle-bottom');
		}
		$('#' + div_id).toggle('fast');
		return false;
	});
});
