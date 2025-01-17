/*******
DISTRIBUTION VISUALIZATION FUNCTIONS
Modified: October 2016
Function: These are the functions for generating charts and graphs with d3js
 *******/

$(document).ready(function () {
    
    //get URL parameters, from http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
    var urlParams;
    (window.onpopstate = function () {
        var match,
        pl = /\+/g, // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) {
            return decodeURIComponent(s.replace(pl, " "));
        },
        query = window.location.search.substring(1);
        
        urlParams = {
        };
        compare = new Array();
        while (match = search.exec(query)) {
            if (decode(match[1]) == 'compare') {
                if (decode(match[2]).length > 0) {
                    compare.push(decode(match[2]));
                }
            } else {
                urlParams[decode(match[1])] = decode(match[2]);
            }
        }
        urlParams[ 'compare'] = compare;
    })();
    
    var path = '../';
    var page = $('#page').text();
    var interfaceType = $('#interface').text();
    
    /**** RENDER CHART ****/
    //render the chart from request parameters on the distribution page
    if (interfaceType == 'distribution' && page == 'page') {
        if (urlParams[ 'dist'] != null && (urlParams[ 'filter'] || urlParams[ 'compare'] != null)) {
            renderDistChart(path, urlParams);
        }
    } else if (interfaceType = 'metrical' && page == 'page') {
        if (urlParams[ 'measurement'] != null && (urlParams[ 'filter'] || urlParams[ 'compare'] != null)) {
            renderMetricalChart(path, urlParams);
        }
    }
    
    //render the chart on button click ajax trigger on ID page--do not reload page with request params
    $('.quant-form').submit(function () {
        if (page == 'record') {
            var formId = $(this).closest('form').attr('id');
            //construct the params
            urlParams = {
            };
            //distribution params
            if ($('#' + formId).find('select[name=dist]').length > 0) {
                urlParams[ 'dist'] = $('#' + formId).find('select[name=dist]').val();
            }
            if ($('#' + formId).find('input[name=type]').length > 0) {
                urlParams[ 'type'] = $('#' + formId).find('input[name=type]').val();
            }
            
            //metrical analysis params
            if ($('#' + formId + ' select[name=measurement]').length > 0) {
                urlParams[ 'measurement'] = $('#' + formId).find('select[name=measurement]').val();
            }
            if ($('#' + formId).children('input[name=from]').length > 0) {
                urlParams[ 'from'] = $('#' + formId).children('input[name=from]').val();
            }
            if ($('#' + formId).children('input[name=to]').length > 0) {
                urlParams[ 'to'] = $('#' + formId).children('input[name=to]').val();
            }
            if ($('#' + formId).children('input[name=interval]').length > 0) {
                urlParams[ 'interval'] = $('#' + formId).children('input[name=interval]').val();
            }
            
            //filter always exists within the ID page
            urlParams[ 'filter'] = $('#' + formId).children('input[name=filter]').val();
            
            //if there are compare queries
            if ($('#' + formId).children('input[name=compare]').length > 0) {
                compare = new Array();
                $('#' + formId).children('input[name=compare]').each(function () {
                    compare.push($(this).val());
                });
                urlParams[ 'compare'] = compare;
            }
            
            params = new Array();
            //set the href value for the CSV download
            Object.keys(urlParams).forEach(function (key) {
                if (key == 'compare') {
                    for (var i = 0, len = urlParams[key].length; i < len; i++) {
                        params.push(key + '=' + urlParams[key][i]);
                    }
                } else if (key == 'filter') {
                    params.push('compare=' + urlParams[key]);
                } else {
                    params.push(key + '=' + urlParams[key]);
                }
            });
            
            //set values and call chart rendering function dependent upon the id of the form
            if (formId == 'distributionForm') {
                //set bookmarkable page URL
                var href = path + 'research/distribution?' + params.join('&');
                $('.chart-container').children('div.control-row').children('a[title=Bookmark]').attr('href', href);
                
                //set CSV download URL
                params.push('format=csv');
                var href = path + 'apis/getDistribution?' + params.join('&');
                $('.chart-container').children('div.control-row').children('a[title=Download]').attr('href', href);
                
                //render the chart
                renderDistChart(path, urlParams);
            } else if (formId == 'metricalForm') {
                //set bookmarkable page URL
                var href = path + 'research/metrical?' + params.join('&');
                $('.chart-container').children('div.control-row').children('a[title=Bookmark]').attr('href', href);
                
                //set CSV download URL
                params.push('format=csv');
                var href = path + 'apis/getMetrical?' + params.join('&');
                $('.chart-container').children('div.control-row').children('a[title=Download]').attr('href', href);
                
                //render the chart
                renderMetricalChart(path, urlParams);
            }
            return false;
        }
    });
    
    /**** FORM MANIPULATION AND VALIDATION ****/
    //when clicking the add-filter link, insert a new filter template into the filter container
    $('.add-filter').click(function () {
        var container = $(this).closest('form').find('.filter-container');
        var formId = $(this).closest('form').attr('id');
        var type = $('#type').text();
        if (type.indexOf('foaf') >= 0) {
            type = 'foaf:Person|foaf:Organization';
        }
        $('#field-template').clone().removeAttr('id').appendTo(container);
        //work on removing the option for the current class
        $('.filter-container').find('option[type="' + type + '"]').remove();
        validate(formId);
        return false;
    });
    
    $('#getDateRange').click(function () {
        var formId = $(this).closest('form').attr('id');
        
        //get all of the queries from the compare fields
        queries = new Array();
        $('input[name=compare]').each(function () {
            queries.push($(this).val());
        });
        
        compareParams = {
            'compare': queries
        }
        
        //show ajax gif
        $('.getDateRange-container').children('span').removeClass('hidden');
        
        //call the getDateRange API to find the absolute earliest and latest dates across all queries
        $.get(path + 'apis/getDateRange', $.param(compareParams, true),
        function (data) {
            //set text inputs
            $('#fromYear').val(Math.abs(data.earliest));
            $('#toYear').val(Math.abs(data.latest));
            
            //set era drop downs
            if (data.earliest < 0) {
                $('#fromEra').val('bc');
            } else {
                $('#fromEra').val('ad');
            }
            
            if (data.latest < 0) {
                $('#toEra').val('bc');
            } else {
                $('#toEra').val('ad');
            }
            
            //automatically set the interval, if blank
            if (isNaN($('#interval').val())) {
                $('#interval').val(5)
            }
            
            $('.getDateRange-container').children('span').addClass('hidden');
            
            //revalidate form
            validate(formId);
        });
        
        return false;
    });
    
    //observe changes in drop down menus for validation
    $('#categorySelect').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('#measurementSelect').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //monitor changes from quantitative analysis drop down menus to execute ajax calls
    $('.filter-container').on('change', '.filter .add-filter-prop', function () {
        var prop = $(this).val();
        var type = $(this).children('option:selected').attr('type');
        var next = $(this).next('.prop-container');
        
        var q = new Array();
        q.push($('#base-query').text());
        //get the filter query from previous parameters
        $(this).parent('.filter').prevAll('.filter').each(function () {
            pair = parseFilter($(this));
            if (pair.length > 0) {
                q.push(pair);
            }
        });
        filter = q.join('; ');
        
        //if the prop is a from or do date, insert date entry template, otherwise get facets from SPARQL
        if (prop == 'from' || prop == 'to') {
            addDate(next);
        } else {
            getFacets(filter, prop, type, next, path);
        }
        
        //display duplicate property alert if there is more than one from or to date
        duplicates = countDates($(this).closest('.filter-container'));
        if (duplicates == true) {
            $(this).closest('.filter-container').children('.duplicate-date-alert').removeClass('hidden');
        } else {
            $(this).closest('.filter-container').children('.duplicate-date-alert').addClass('hidden');
        }
    });
    
    $('.filter-container').on('change', '.filter .prop-container .add-filter-object', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //validate on date change
    $('.filter-container').on('change', '.filter .prop-container span input.year', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('.filter-container').on('change', '.filter .prop-container span select.era', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //validate on measurement analysis date range changes
    $('#fromYear').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('#fromEra').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('#toYear').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('#toEra').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $('#interval').change(function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //delete the compare/filter query pair
    $('.filter-container').on('click', '.filter .control-container .remove-query', function () {
        var container = $(this).closest('.filter-container');
        var formId = $(this).closest('form').attr('id');
        $(this).closest('.filter').remove();
        
        //display duplicate property alert if there is more than one from or to date
        duplicates = countDates(container);
        if (duplicates == true) {
            container.children('.duplicate-date-alert').removeClass('hidden');
        } else {
            container.children('.duplicate-date-alert').addClass('hidden');
        }
        
        validate(formId);
        return false;
    });
    
    //on page load, populate the SPARQL-based query filters
    $('.quant-form').find('.filter').each(function () {
        var formId = $(this).closest('form').attr('id');
        var prop = $(this).children('.add-filter-prop').val();
        var type = $(this).children('.add-filter-prop').children('option:selected').attr('type');
        var next = $(this).children('.add-filter-prop').next('.prop-container');
        
        if (next.children('span.filter').text().length > 0) {
            var filter = next.children('span.filter').text();
        } else {
            var filter = '';
        }
        
        if (prop == 'from' || prop == 'to') {
            validate(formId);
        } else {
            getFacets(filter, prop, type, next, path);
        }
    });
    
    /***COMPARE***/
    //add dataset for comparison
    $('.add-compare').click(function () {
        var container = $(this).closest('form').find('.compare-master-container');
        var formId = $(this).closest('form').attr('id');
        $('#compare-container-template').clone().removeAttr('id').appendTo(container);
        
        //automatically insert a property-object query pair
        $('#field-template').clone().removeAttr('id').appendTo('.compare-master-container .compare-container:last');
        validate(formId);
        return false;
    });
    //add property-object facet into dataset
    $('.compare-master-container').on('click', 'h4 small .add-compare-field', function () {
        $('#field-template').clone().removeAttr('id').appendTo($(this).closest('.compare-container'));
        var formId = $(this).closest('form').attr('id');
        validate(formId);
        
        var count = $(this).closest('.compare-container').children('.filter').length;
        
        //toggle the alert box when there aren't any filters
        if (count > 0) {
            $(this).closest('.compare-container').children('.empty-query-alert').addClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.empty-query-alert').removeClass('hidden');
        }
        
        return false;
    });
    
    //get facets on property drop-down list change
    $('.compare-master-container').on('change', '.compare-container .filter .add-filter-prop', function () {
        var prop = $(this).val();
        var type = $(this).children('option:selected').attr('type');
        var next = $(this).next('.prop-container');
        
        var q = new Array();
        //get the filter query from previous parameters
        $(this).parent('.filter').prevAll('.filter').each(function () {
            pair = parseFilter($(this));
            if (pair.length > 0) {
                q.push(pair);
            }
        });
        filter = q.join('; ');
        
        //if the prop is a from or do date, insert date entry template, otherwise get facets from SPARQL
        if (prop == 'from' || prop == 'to') {
            addDate(next);
        } else {
            getFacets(filter, prop, type, next, path);
        }
        
        //display duplicate property alert if there is more than one from or to date
        duplicates = countDates($(this).closest('.compare-container'));
        if (duplicates == true) {
            $(this).closest('.compare-container').children('.duplicate-date-alert').removeClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.duplicate-date-alert').addClass('hidden');
        }
    });
    
    //validate on object drop-down list change
    $(' .compare-master-container').on('change', '.compare-container .filter .prop-container .add-filter-object', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    
    //delete dataset query
    $(' .compare-master-container').on('click', '.compare-container h4 small .remove-dataset', function () {
        var formId = $(this).closest('form').attr('id');
        $(this).closest('.compare-container').remove();
        validate(formId);
        return false;
    });
    
    //delete property-object pair
    $(' .compare-master-container').on('click', '.compare-container .filter .control-container .remove-query', function () {
        var formId = $(this).closest('form').attr('id');
        var count = $(this).closest('.compare-container').children('.filter').length;
        
        //toggle the alert box when there aren't any filters
        if (count == 1) {
            $(this).closest('.compare-container').children('.empty-query-alert').removeClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.empty-query-alert').addClass('hidden');
        }
        
        //store the container object to processing after deletion of filter
        var container = $(this).closest('.compare-container');
        $(this).closest('.filter').remove();
        
        //display duplicate property alert if there is more than one from or to date. must count after deletion of filter
        duplicates = countDates(container);
        if (duplicates == true) {
            container.children('.duplicate-date-alert').removeClass('hidden');
        } else {
            container.children('.duplicate-date-alert').addClass('hidden');
        }
        validate(formId);
        return false;
    });
    
    //validate on date change
    $(' .compare-master-container').on('change', '.compare-container .filter .prop-container span input.year', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
    $(' .compare-master-container').on('change', '.compare-container .filter .prop-container span select.era', function () {
        var formId = $(this).closest('form').attr('id');
        validate(formId);
    });
});

function parseFilter(container) {
    var pair;
    
    //only generate filter if both the property and object have values
    if (container.children('.add-filter-prop').val().length > 0) {
        //evaluate dates vs. facets
        if (container.children('.add-filter-prop').val() == 'to' || container.children('.add-filter-prop').val() == 'from') {
            var year = container.children('.prop-container').children('span').children('input.year').val();
            var era = container.children('.prop-container').children('span').children('select.era').val();
            
            if (era == 'bc') {
                year = year * -1;
            }
            
            pair = container.children('.add-filter-prop').val() + ' ' + year;
        } else if (container.children('.add-filter-prop').val() && container.children('.prop-container').children('.add-filter-object').val()) {
            pair = container.children('.add-filter-prop').val() + ' ' + container.children('.prop-container').children('.add-filter-object').val();
        }
    }
    
    return pair;
}

function renderDistChart(path, urlParams) {
    if (urlParams[ 'dist'].indexOf('nmo:has') != -1) {
        var distValue = urlParams[ 'dist'].replace('nmo:has', '').toLowerCase();
    } else {
        var distValue = urlParams[ 'dist'];
    }
    var distLabel = $('select[name=dist] option:selected').text();
    
    if (urlParams[ 'type'] == 'count') {
        var y = 'count';
    } else {
        var y = 'percentage';
    }
    
    $.get(path + 'apis/getDistribution', $.param(urlParams, true),
    function (data) {
        $('#distribution .chart-container').removeClass('hidden');
        $('#distribution-chart').html('');
        $('#distribution-chart').height(600);
        var visualization = d3plus.viz().container("#distribution-chart").data(data).type("bar").id('subset').x({
            'value': distValue, 'label': distLabel
        }).y(y).legend({
            "value": true, "size": 50
        }).color({
            "value": "subset"
        }).draw();
    });
}

function renderMetricalChart(path, urlParams) {
    $('#metrical .chart-container').removeClass('hidden');
    $('#metrical-chart').html('');
    $('#metrical-chart').height(600);
    
    if ($.isNumeric(urlParams[ 'interval'])) {
        $.get(path + 'apis/getMetrical', $.param(urlParams, true),
        function (data) {
            var visualization = d3plus.viz().container("#metrical-chart").data(data).type('line').id('subset').y({
                'value': 'average'
            }).x({
                'value': 'value', 'label': 'Date Range'
            }).tooltip([ "label", "average"]).legend({
                "size":[20, 50], 'data': false
            }).size(5).color({
                "value": "subset"
            }).draw();
        });
    } else {
        $.get(path + 'apis/getMetrical', $.param(urlParams, true),
        function (data) {
            var visualization = d3plus.viz().container("#metrical-chart").data(data).type('bar').id('subset').y('average').x('value').legend({
                "size": 50
            }).color({
                "value": "subset"
            }).draw();
        });
    }
}