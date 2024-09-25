$(document).ready(function () {
    $('#search_button').click(function () {
        var query = new Array();
        var type = $('#type_filter').val();
        var role = $('#role_filter').val();
        var field = $('#field_filter').val();
        var conceptScheme = $('#conceptScheme_filter').val();
        var text = $('#search_text').val();
        
        if (type.length > 0) {
            query.push(type);
        }
        if (field.length > 0) {
            query.push(field);
        }
        if (conceptScheme.length > 0) {
            query.push(conceptScheme);
        }
        if (text.length > 0) {
            query.push(text);
        }
        if (role.length > 0 && $('#role_filter').prop('disabled') == false) {
            query.push(role);
        }
        
        $('.letter-button').each(function () {
            if ($(this).hasClass('active')) {
                query.push('letter_facet:%22' + $(this).text() + '%22');
            }
        });
        
        if (query.length > 0) {
            $('#filter-form').children('input[name=q]').attr('value', query.join(' AND '));
        }
        
        if ($('#sort_results').val().length > 0) {
            $('#filter-form').children('input[name=sort]').prop('disabled', false);
            $('#filter-form').children('input[name=sort]').attr('value', $('#sort_results').val());
        }
    });
    
    $('.letter-button').click(function () {
        if ($(this).hasClass('active')) {
            $(this).removeClass('active');
            return false;
        } else {
            $(this).addClass('active');
            return false;                        
        }
    });
    
    //clear selected letters
    $('#clear_letter_button').click(function () {
        $('.letter-button').each(function () {
            $(this).removeClass('active');
        });
        return false;
    });
    
    //disable inputs, reset form
    $('#clear-query').click(function () {
        $('#filter-form').children('input[name=sort]').prop('disabled', true);
        $('#filter-form').children('input[name=q]').prop('disabled', true);
        $('#filter-form').children('input[name=layout]').prop('disabled', true);
    });
    
    $('.toggle-button').click(function () {
        var div_id = $(this).attr('id').split('-')[1] + '-div';
        if ($(this).children('span#toggle-glyphicon').hasClass('glyphicon-triangle-bottom')) {
            $(this).children('span#toggle-glyphicon').removeClass('glyphicon-triangle-bottom');
            $(this).children('span#toggle-glyphicon').addClass('glyphicon-triangle-right');
        } else {
            $(this).children('span#toggle-glyphicon').removeClass('glyphicon-triangle-right');
            $(this).children('span#toggle-glyphicon').addClass('glyphicon-triangle-bottom');
        }
        $('#' + div_id).toggle('fast');
        return false;
    });
    
    $('#type_filter').change(function () {
        var val = $(this).val();
        
        if (val.indexOf('Person') > 0 || val.indexOf('Organization') > 0) {
            $('.role_div').show();
            $('#role_filter').prop('disabled', false);
        } else {
            $('.role_div').hide();
            $('#role_filter').prop('disabled', true);
        }
    });
});