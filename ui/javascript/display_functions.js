/*******
DISPLAY FUNCTIONS
Modified: August 2021
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
    
    //show/hide sections
    $('.toggle-button').click(function () {
        var div = $(this).attr('id').split('-')[1];
        $('#' + div).toggle();
        
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
    
    //if there is a div with a id=ajaxList, then initiate ajax call
    if ($('#ajaxList').length > 0) {
        var path = '../';
        var id = $('title').attr('id');
        var type = $('#type').text();
        
        $.get(path + 'ajax/listTypes', {
            id: id, type: type
        },
        function (data) {
            $('#ajaxList').html(data);
        });
    }
    
    if ($('#listAgents').length > 0) {
        var path = '../';
        var id = $('title').attr('id');
        var type = $('#type').text();
        
        $.get(path + 'ajax/listAgents', {
            id: id
        },
        function (data) {
            $('#listAgents').html(data);
        });
    }
    
    //sorting
    $('#ajaxList').on('click', '#ajaxList-div table thead tr th .sort-types', function () {
        var path = '../';
        var id = $('title').attr('id');
        var type = $('#type').text();
        var sort = unescape($(this).attr('href').split('=')[1]);
        
        //alert(sort);
        
        
        $.get(path + 'ajax/listTypes', {
            id: id, type: type, sort: sort
        },
        function (data) {
            $('#ajaxList').html(data);
        });
        
        return false;
    });
    
    //pagination
    $('#ajaxList').on('click', '.paging_div .page-nos .btn-toolbar .btn-group a.btn', function (event) {
        var path = '../';
        var id = $('title').attr('id');
        var type = $('#type').text();
        
        urlParams = {
            'id': id, 'type': type
        };
        
        //parse the page and sort from the HTML link
        var match,
        pl = /\+/g, // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) {
            return decodeURIComponent(s.replace(pl, " "));
        },
        query = $(this).attr('href').substring(1);
        
        
        compare = new Array();
        while (match = search.exec(query)) {
            urlParams[decode(match[1])] = decode(match[2]);
        }
        
        $.get(path + 'ajax/listTypes', $.param(urlParams, true),
        function (data) {
            $('#ajaxList').html(data);
        });
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