$(document).ready(function () {
	$('#search_button').click(function () {
		var exclude = new Array();
		$('.facet-checkbox:not(:checked)').each(function () {
			exclude.push($(this).val());
		});
		
		var search_string = $('#qs_query').val();
		
		if (exclude.length > 0) {
			var sep = '';
			if (search_string.length > 0) {
				sep = '&';
			}
			var exclude_string = sep + 'exclude=' + exclude.join('&exclude=');
		}
		
		var query = (search_string.length > 0 || exclude.length > 0 ? '?': '') + (search_string.length > 0 ? 'query=' + search_string: '') + (exclude.length > 0 ? exclude_string: '');
		window.location = '../browse/' + query;
		return false;
	});
	$('.checkall').click(function () {
		$('.facet-checkbox').prop("checked", true);
	});
	$('.uncheckall').click(function () {
		$('.facet-checkbox').prop("checked", false);
	});
});