$(document).ready(function () {
	$('#search_button') .click(function () {
		var query = new Array();
		var type = $('#type_filter').val();
		var role = $('#role_filter').val();
		var field = $('#field_filter').val();
		var text = $('#search_text').val();
		
		if (type.length > 0) {
			query.push(type);
		}
		if (field.length > 0) {
			query.push(field);
		}
		if (text.length > 0) {
			query.push(text);
		}
		if (role.length > 0 &&  $('#role_filter').prop('disabled') == false) {
			query.push(role);
		}
		
		if (query.length > 0) {
			$('#filter-form').children('input[name=q]').attr('value', query.join(' AND '));	
		}			
		
		if ($('#sort_results').val().length > 0) {
			$('#filter-form').children('input[name=sort]').prop('disabled', false);
			$('#filter-form').children('input[name=sort]').attr('value', $('#sort_results').val());
		}		
	});
	
	//disable inputs, reset form
	$('#clear-query').click(function(){
		$('#filter-form').children('input[name=sort]').prop('disabled', true);
		$('#filter-form').children('input[name=q]').prop('disabled', true);
	});
	
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
	
	$('#type_filter').change(function(){
		var val = $(this).val();
		
		if (val.indexOf('Person') > 0 || val.indexOf('Organization') > 0){
			$('.role_div').show();
			$('#role_filter').prop('disabled', false);
		} else {
			$('.role_div').hide();
			$('#role_filter').prop('disabled', true);
		}
	});
});