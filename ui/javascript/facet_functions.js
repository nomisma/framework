/*******
SPARQL-BASED FACET FORM FUNCTIONS
Modified: January 2025
Function: These are the functions for facet-based web forms used for data and geographic visualization interfaces
 *******/

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

function generateFilter(formId) {
    var q = new Array($('#base-query').text());
    //iterate through additional features
    $('#' + formId).find('.filter-container .filter').each(function () {
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
function addDate(next) {
    template = $('#date-container-template').clone().removeAttr('id');
    var formId = $(next).closest('form').attr('id');
    next.html(template);
    validate(formId);
}

//get the associated facets from thet getSparqlFacets web service
function getFacets(filter, prop, type, next, path) {
    var formId = $(next).closest('form').attr('id');
    if (type != null) {
        //define ajax parameters
        params = {
            "facet": prop
        }
        
        params.filter = filter;
        
        //add query, if available (prepopulating facet drop down menus)
        if (next.children('span.query').text().length > 0) {
            params.query = next.children('span.query').text();
        }
        
        //set ajax loader
        loader = $('#ajax-loader-template').clone().removeAttr('id');
        next.html(loader);
        
        $.get(path + 'ajax/getSparqlFacets', params,
        function (data) {
            next.html(data);
            validate(formId);
        });
    } else {
        next.children('.add-filter-object').remove();
        validate(formId);
    }
}

function validate(formId) {
    var page = $('#page').text();
    var elements = new Array();
    //evaluate each portion of the form
    
    //ensure category drop down contains a value, but only for the distribution page
    if (formId == 'distributionForm') {
        if ($('#categorySelect').val()) {
            elements.push(true);
        } else {
            elements.push(false);
        }
    } else if (formId == 'metricalForm') {
        if ($('#measurementSelect').val()) {
            elements.push(true);
        } else {
            elements.push(false);
        }
    }
    
    //evaluate the filter from record page
    if ($('#' + formId).find('.filter-container').length > 0) {
        $('#' + formId + ' .filter').each(function () {
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
    $('#' + formId + ' .compare-master-container .compare-container').each(function () {
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
    
    //validate date range query for measurement analysis, only validate if there is a value in one or more relevant elements
    if ($('#' + formId + ' #measurementRange-container').length > 0) {
        var fromYear = $('#fromYear').val();
        var toYear = $('#toYear').val();
        var interval = $('#interval').val();
        
        //check to see if any values have been set
        if ($.isNumeric(fromYear) || $.isNumeric(toYear) || $.isNumeric(interval)) {
            //if they are all numeric values, then the controls are valid
            if ($.isNumeric(fromYear) && $.isNumeric(toYear) && $.isNumeric(interval)) {
                if (fromYear > 0 && toYear > 0) {
                    //be sure that fromYear is less than toYear
                    if ($('#fromEra').val() == 'bc') {
                        fromYear = fromYear * -1;
                    }
                    if ($('#toEra').val() == 'bc') {
                        toYear = toYear * -1;
                    }
                    if (fromYear >= toYear) {
                        elements.push(false);
                        $('.measurementRange-alert').removeClass('hidden');
                    } else {
                        elements.push(true);
                        $('.measurementRange-alert').addClass('hidden');
                    }
                    
                    //evaluate the interval and only allow the interval of 1 year for a range of <= 30 years
                    if (interval == 1) {
                        if (toYear - fromYear > 30) {
                            elements.push(false);
                            $('.interval-alert').removeClass('hidden');
                        } else {
                            elements.push(true);
                            $('.interval-alert').addClass('hidden');
                        }
                    } else {
                        $('.interval-alert').addClass('hidden');
                    }
                } else {
                    elements.push(false);
                    $('.measurementRange-alert').removeClass('hidden');
                }
            } else {
                elements.push(false);
                $('.measurementRange-alert').removeClass('hidden');
            }
        } else {
            //hide the date alert if no values have been set
            $('.measurementRange-alert').addClass('hidden');
            $('.interval-alert').addClass('hidden');
        }
    }    
   
    
    //if there is a false element to the form OR if there is only one element (i.e., the category, then the form is invalid
    if (elements.indexOf(false) !== -1) {
        var valid = false;
    } else {
        if (page == 'page') {
            //there must be at least one compare container on the analsyis page
            if ($('#' + formId + ' .compare-master-container .compare-container').length >= 1) {
                var valid = true;
            } else {
                var valid = false;
            }
        } else {
            var valid = true;
        }
    }
    
    //enable/disable button
    if (valid == true) {
        //generate the filter query and assign the value to the hidden input
        q = generateFilter(formId);
        $('#' + formId + ' input[name=filter]').val(q);
        
        //for each comparison query, insert an input, but clear input[name=compare] first
        $('#' + formId).find('input[name=compare]').remove();
        $('#' + formId + ' .compare-master-container .compare-container').each(function () {
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
        
        //insert inputs for measurementRange query
        if ($('#' + formId + ' #measurementRange-container').length > 0) {
            if ($.isNumeric($('#fromYear').val()) && $.isNumeric($('#toYear').val()) && $.isNumeric($('#interval').val())) {
                var fromYear = $('#fromYear').val();
                var toYear = $('#toYear').val();
                var interval = $('#interval').val();
                
                if ($('#fromEra').val() == 'bc') {
                    fromYear = fromYear * -1;
                }
                if ($('#toEra').val() == 'bc') {
                    toYear = toYear * -1;
                }
                //delete existing inputs
                $('#' + formId).children('input[name=from]').remove();
                $('#' + formId).children('input[name=to]').remove();
                $('#' + formId).children('input[name=interval]').remove();
                
                //insert new inputs
                $('#' + formId).append('<input name="from" type="hidden" value="' + fromYear + '">');
                $('#' + formId).append('<input name="to" type="hidden" value="' + toYear + '">');
                $('#' + formId).append('<input name="interval" type="hidden" value="' + interval + '">');
            } else {
                $('#' + formId).children('input[name=from]').remove();
                $('#' + formId).children('input[name=to]').remove();
                $('#' + formId).children('input[name=interval]').remove();
            }
        }
        
        //enable the button
        $('#' + formId).children('.visualize-submit').prop("disabled", false);
        
        //show the button to automatically generate the date range for the given queries.
        $('.getDateRange-container').removeClass('hidden');
    } else {
        $('#' + formId).children('.visualize-submit').prop("disabled", true);
        $('.getDateRange-container').addClass('hidden');
    }
}