$(document).ready(function () {
	$('#search_button') .click(function () {
		var query = new Array();
		var filter = $('#search_filter').val();
		var text = $('#search_text').val();
		
		if (filter.length > 0) {
			query.push(filter);
		}
		if (text.length > 0) {
			query.push(text);
		}
		$(this).siblings('input[name=q]').attr('value', query.join(' AND '));
	});
});