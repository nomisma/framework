$(document).ready(function () {
	$('#search_button') .click(function () {
		var query = new Array();
		var filter = $('#type_filter').val();
		var role = $('#role_filter').val();
		var text = $('#search_text').val();
		
		if (filter.length > 0) {
			query.push(filter);
		}
		if (text.length > 0) {
			query.push(text);
		}
		if (role.length > 0 &&  $('#role_filter').prop('disabled') == false) {
			query.push(role);
		}
		$(this).siblings('input[name=q]').attr('value', query.join(' AND '));
		
		$(this).siblings('input[name=sort]').attr('value', $('#sort_results').val());
	});
	
	$('#type_filter').change(function(){
		var val = $(this).val();
		
		if (val.indexOf('Person') > 0 || val.indexOf('Organization') > 0){
			$('.role_div').css({'display':'inline'});
			$('#role_filter').prop('disabled', false);
		} else {
			$('.role_div').hide();
			$('#role_filter').prop('disabled', true);
		}
	});
});