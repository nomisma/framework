/*******
VISUALIZATION FUNCTIONS
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
    
    /**** RENDER CHART ****/
    //render the chart from request parameters on the distribution page
    if (page == 'page') {
        if (urlParams[ 'dist'] != null && (urlParams[ 'filter'] || urlParams[ 'compare'] != null)) {
            renderChart(path, urlParams);
        }
    }
    
    //render the chart on button click ajax trigger on ID page--do not reload page with request params
    $('#distributionForm').submit(function () {
        if (page == 'record') {
            //construct the params
            urlParams = {
            };
            urlParams[ 'dist'] = $('select[name=dist]').val();
            urlParams[ 'filter'] = $('input[name=filter]').val();
            urlParams[ 'type'] = $('input[name=type]').val();
            //if there are compare queries
            if ($('input[name=compare]').length > 0) {
                compare = new Array();
                $('input[name=compare]').each(function () {
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
            
            //set bookmarkable page URL
            var href = path + 'research/distribution?' + params.join('&');
            $('#dist-chart-container').children('div.control-row').children('a[title=Bookmark]').attr('href', href);
            
            //set CSV download URL
            params.push('format=csv');
            href = path + 'apis/getCount?' + params.join('&');
            $('#dist-chart-container').children('div.control-row').children('a[title=Download]').attr('href', href);
            
            //render the chart
            renderChart(path, urlParams);
            
            return false;
        }
    });
    
    /**** FORM MANIPULATION AND VALIDATION ****/
    //when clicking the add-filter link, insert a new filter template into the filter container
    $('#add-filter').click(function () {
        var type = $('#type').text();
        if (type.indexOf('foaf') >= 0) {
            type = 'foaf:Person|foaf:Organization';
        }
        $('#field-template').clone().removeAttr('id').appendTo('#filter-container');
        //work on removing the option for the current class
        $('#filter-container').find('option[type="' + type + '"]').remove();
        validate();
        return false;
    });
    
    //observe changes in drop down menus for validation
    $('#categorySelect').change(function () {
        validate();
    });
    
    //monitor changes from quantitative analysis drop down menus to execute ajax calls
    $('#filter-container').on('change', '.filter .add-filter-prop', function () {
        var prop = $(this).val();
        var type = $(this).children('option:selected').attr('type');
        var next = $(this).next('.prop-container');
        
        //if the prop is a from or do date, insert date entry template, otherwise get facets from SPARQL
        if (prop == 'from' || prop == 'to') {
            addDate(mode = 'filter', next);
        } else {
            getFacets(mode = 'filter', prop, type, next, path);
        }
        
        //display duplicate property alert if there is more than one from or to date
        duplicates = countDates($(this).closest('#filter-container'));
        if (duplicates == true) {
            $(this).closest('#filter-container').children('.duplicate-date-alert-box').removeClass('hidden');
        } else {
            $(this).closest('#filter-container').children('.duplicate-date-alert-box').addClass('hidden');
        }
    });
    
    $('#filter-container').on('change', '.filter .prop-container .add-filter-object', function () {
        validate();
    });
    
    //validate on date change
    $('#filter-container').on('change', '.filter .prop-container span input.year', function () {
        validate();
    });
    $('#filter-container').on('change', '.filter .prop-container span select.era', function () {
        validate();
    });
    
    //delete the compare/filter query pair
    $('#filter-container').on('click', '.filter .control-container .remove-query', function () {
        var container = $(this).closest('#filter-container');
        $(this).closest('.filter').remove();
        
        //display duplicate property alert if there is more than one from or to date
        duplicates = countDates(container);
        if (duplicates == true) {
            container.children('.duplicate-date-alert-box').removeClass('hidden');
        } else {
            container.children('.duplicate-date-alert-box').addClass('hidden');
        }
        
        validate();
        return false;
    });
    
    //on page load, populate the SPARQL-based query filters
    $('#distributionForm').find('.filter').each(function () {
        var prop = $(this).children('.add-filter-prop').val();
        var type = $(this).children('.add-filter-prop').children('option:selected').attr('type');
        var next = $(this).children('.add-filter-prop').next('.prop-container');
        var mode = $(this).parent('div').attr('class') == 'compare-container' ? 'compare': 'filter';
        
        
        if (prop == 'from' || prop == 'to') {
            validate();
        } else {
            getFacets(mode, prop, type, next, path);
        }
    });
    
    /***COMPARE***/
    //add dataset for comparison
    $('#add-compare').click(function () {
        $('#compare-container-template').clone().removeAttr('id').appendTo('#compare-master-container');
        
        //automatically insert a property-object query pair
        $('#field-template').clone().removeAttr('id').appendTo('#compare-master-container .compare-container:last');
        validate();
        return false;
    });
    //add property-object facet into dataset
    $('#compare-master-container').on('click', 'h4 small .add-compare-field', function () {
        $('#field-template').clone().removeAttr('id').appendTo($(this).closest('.compare-container'));
        validate();
        
        var count = $(this).closest('.compare-container').children('.filter').length;
        
        //toggle the alert box when there aren't any filters
        if (count > 0) {
            $(this).closest('.compare-container').children('.empty-query-alert-box').addClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.empty-query-alert-box').removeClass('hidden');
        }
        
        return false;
    });
    
    //get facets on property drop-down list change
    $('#compare-master-container').on('change', '.compare-container .filter .add-filter-prop', function () {
        var prop = $(this).val();
        var type = $(this).children('option:selected').attr('type');
        var next = $(this).next('.prop-container');
        
        //if the prop is a from or do date, insert date entry template, otherwise get facets from SPARQL
        if (prop == 'from' || prop == 'to') {
            addDate(mode = 'compare', next);
        } else {
            getFacets(mode = 'compare', prop, type, next, path);
        }
        
        //display duplicate property alert if there is more than one from or to date
        duplicates = countDates($(this).closest('.compare-container'));
        if (duplicates == true) {
            $(this).closest('.compare-container').children('.duplicate-date-alert-box').removeClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.duplicate-date-alert-box').addClass('hidden');
        }
    });
    
    //validate on object drop-down list change
    $(' #compare-master-container').on('change', '.compare-container .filter .prop-container .add-filter-object', function () {
        validate();
    });
    
    //delete dataset query
    $(' #compare-master-container').on('click', '.compare-container h4 small .remove-dataset', function () {
        $(this).closest('.compare-container').remove();
        validate();
        return false;
    });
    
    //delete property-object pair
    $(' #compare-master-container').on('click', '.compare-container .filter .control-container .remove-query', function () {
        var count = $(this).closest('.compare-container').children('.filter').length;
        
        //toggle the alert box when there aren't any filters
        if (count == 1) {
            $(this).closest('.compare-container').children('.empty-query-alert-box').removeClass('hidden');
        } else {
            $(this).closest('.compare-container').children('.empty-query-alert-box').addClass('hidden');
        }
        
        //store the container object to processing after deletion of filter
        var container = $(this).closest('.compare-container');
        $(this).closest('.filter').remove();
        
        //display duplicate property alert if there is more than one from or to date. must count after deletion of filter
        duplicates = countDates(container);
        if (duplicates == true) {
            container.children('.duplicate-date-alert-box').removeClass('hidden');
        } else {
            container.children('.duplicate-date-alert-box').addClass('hidden');
        }
        validate();
        return false;
    });
    
    //validate on date change
    $(' #compare-master-container').on('change', '.compare-container .filter .prop-container span input.year', function () {
        validate();
    });
    $(' #compare-master-container').on('change', '.compare-container .filter .prop-container span select.era', function () {
        validate();
    });
});

//count occurrences of from and to date query fields to display error warning or negate query validation
function countDates(self) {
    var toCount = 0;
    var fromCount = 0;
    self.siblings().addBack().children('.filter').children('.add-filter-prop').each(function () {
        if ($(this).val() == 'to') {
            toCount++;
        } else if ($(this).val() == 'from') {
            fromCount++;
        }
    });
    
    if (fromCount > 1 || toCount > 1) {
        return true;
    } else {
        return false;
    }
}

//insert the from/to date template
function addDate(mode, next) {
    template = $('#date-container-template').clone().removeAttr('id');
    next.html(template);
    validate();
}

//get the associated facets from thet getSparqlFacets web service
function getFacets(mode, prop, type, next, path) {
    if (type != null) {
        //define ajax parameters
        params = {
            "facet": prop
        }
        
        //add filter if we are filtering against the current Nomisma ID
        if (mode == 'filter') {
            params.filter = $('#base-query').text();
        }
        
        //add query, if available (prepopulating facet drop down menus)
        if (next.children('span').text().length > 0) {
            params.query = next.children('span').text();
        }
        
        //set ajax loader
        loader = $('#ajax-loader-template').clone().removeAttr('id');
        next.html(loader);
        
        $.get(path + 'ajax/getSparqlFacets', params,
        function (data) {
            next.html(data);
            validate();
        });
    } else {
        next.children('.add-filter-object').remove();
        validate();
    }
}

function validate() {
    var page = $('#page').text();
    var elements = new Array();
    
    //evaluate each portion of the form
    
    //ensure category drop down contains a value
    if ($('#categorySelect').val()) {
        elements.push(true);
    } else {
        elements.push(false);
    }
    
    //evaluate the filter from record page
    if ($('#filter-container').length > 0) {
        $('#filter-container .filter').each(function () {
            if ($(this).children('.add-filter-prop').val() == 'to' || $(this).children('.add-filter-prop').val() == 'from') {
                var year = $(this).children('.prop-container').children('span').children('input.year').val();
                if ($.isNumeric(year)) {
                    elements.push(true);
                } else {
                    elements.push(false);
                }
            } else {
                if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
                    elements.push(true);
                } else {
                    elements.push(false);
                }
            }
        });
    }
    
    //evaluate every compare query
    $('#compare-master-container .compare-container').each(function () {
        //look for duplicate from or to dates
        duplicates = countDates($(this));
        if (duplicates == true) {
            elements.push(false);
        }
        
        //if there are no filters in the compare container, then the compare query is false
        if ($(this).children('.filter').length > 0) {
            $(this).children('.filter').each(function () {
                //if the prop is to for from, then validate the integer
                if ($(this).children('.add-filter-prop').val() == 'to' || $(this).children('.add-filter-prop').val() == 'from') {
                    var year = $(this).children('.prop-container').children('span').children('input.year').val();
                    if ($.isNumeric(year)) {
                        elements.push(true);
                    } else {
                        elements.push(false);
                    }
                } else {
                    //otherwise check for value of the object drop-down menu
                    if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
                        elements.push(true);
                    } else {
                        elements.push(false);
                    }
                }
            });
        } else {
            elements.push(false);
        }
    });
    
    //if there is a false element to the form OR if there is only one element (i.e., the category, then the form is invalid
    if (elements.indexOf(false) !== -1) {
        var valid = false;
    } else {
        if (page == 'page' && elements.length == 1) {
            var valid = false;
        } else {
            var valid = true;
        }
    }
    
    //enable/disable button
    if (valid == true) {
        $('#visualize-submit').prop("disabled", false);
        
        //generate the filter query and assign the value to the hidden input
        q = generateFilter();
        $('input[name=filter]').val(q);
        
        //for each comparison query, insert an input, but clear input[name=compare] first
        $('input[name=compare]').remove();
        $('#compare-master-container .compare-container').each(function () {
            var formId = $(this).closest('form').attr('id');
            var q = new Array();
            $(this).children('.filter').each(function () {
                //evaluate dates vs. facets
                if ($(this).children('.add-filter-prop').val() == 'to' || $(this).children('.add-filter-prop').val() == 'from') {
                    var year = $(this).children('.prop-container').children('span').children('input.year').val();
                    var era = $(this).children('.prop-container').children('span').children('select.era').val();
                    
                    if (era == 'bc') {
                        year = year * -1;
                    }
                    
                    q.push($(this).children('.add-filter-prop').val() + ' ' + year);
                } else if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
                    q.push($(this).children('.add-filter-prop').val() + ' ' + $(this).children('.prop-container').children('.add-filter-object').val());
                }
            });
            query = q.join('; ');
            $('#' + formId).append('<input name="compare" type="hidden" value="' + query + '">');
        });
    } else {
        $('#visualize-submit').prop("disabled", true);
    }
}

function generateFilter() {
    var q = new Array($('#base-query').text());
    
    //iterate through additional features
    $('#filter-container .filter').each(function () {
        //evaluate dates vs. facets
        if ($(this).children('.add-filter-prop').val() == 'to' || $(this).children('.add-filter-prop').val() == 'from') {
            var year = $(this).children('.prop-container').children('span').children('input.year').val();
            var era = $(this).children('.prop-container').children('span').children('select.era').val();
            
            if (era == 'bc') {
                year = year * -1;
            }
            q.push($(this).children('.add-filter-prop').val() + ' ' + year);
        } else if ($(this).children('.add-filter-prop').val() && $(this).children('.prop-container').children('.add-filter-object').val()) {
            q.push($(this).children('.add-filter-prop').val() + ' ' + $(this).children('.prop-container').children('.add-filter-object').val());
        }
    });
    
    query = q.join('; ');
    
    return query;
}

function renderChart(path, urlParams) {
    var distLabel = $('select[name=dist] option:selected').text().toLowerCase();
    if (urlParams[ 'type'] == 'count') {
        var y = 'count';
    } else {
        var y = 'percentage';
    }
    
    $.get(path + 'apis/getCount', $.param(urlParams, true),
    function (data) {
        $('#dist-chart-container').removeClass('hidden');
        $('#chart').html('');
        $('#chart').height(600);
        var visualization = d3plus.viz().container("#chart").data(data).type("bar").id('subset').x(distLabel).y(y).legend({
            "value": true, "size": 50
        }).color({
            "value": "subset"
        }).draw();
    });
}