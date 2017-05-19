/*******
DISPLAY FUNCTIONS
Modified: August 2016
Function: These are javascript functions responsible for minor features on the HTML page for IDs,
e.g., showing and hiding SPARQL query divs
 *******/

$(document).ready(function () {
    //toggle divs to be hidden or shown (SPARQL query)
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
    
    //listTypes
    $('.page-section').on('click', 'h3 small .toggle-button', function () {
        var div = $(this).attr('id').split('-')[1];
        $('#' + div + '-div').toggle();
        
        //replace minus with plus and vice versa
        var span = $(this).children('span');
        if (span.attr('class').indexOf('right') > 0) {
            span.removeClass('glyphicon-triangle-right');
            span.addClass('glyphicon-triangle-bottom');
        } else {
            span.removeClass('glyphicon-triangle-bottom');
            span.addClass('glyphicon-triangle-right');
        }
        return false;
    });
    
    //toggle quantitative analysis form visibility
    $('#quant .toggle-button').click(function () {
        var div = $(this).attr('id').split('-')[1];
        $('#' + div).toggle();
        
        //replace triangles
        var span = $(this).children('span');
        if (span.attr('class').indexOf('right') > 0) {
            span.removeClass('glyphicon-triangle-right');
            span.addClass('glyphicon-triangle-bottom');
        } else {
            span.removeClass('glyphicon-triangle-bottom');
            span.addClass('glyphicon-triangle-right');
        }
        return false;
    });
    
    //if there is a div with a id=listTypes, then initiate ajax call
    if ($('#listTypes').length > 0) {
        var path = '../';
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
});