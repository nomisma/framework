/* Function: Javascript functions for the SPARQL query page */

$(document).ready(function () {
    
    //initiate CodeMirror syntax highlighting for the SPARQL query textarea
    var editor = CodeMirror.fromTextArea(document.getElementById("code"), {
        mode: "application/x-sparql-query",
        matchBrackets: true
    });
    
    //monitor CodeMirror for changes to text area to hide/show prefix buttons
    editor.on('change', function (e) {
        //empty array of current prefixes
        var prefixes = new Array();
        
        var query = editor.getValue();
        var lines = query.split('\n');
        for (var i = 0; i < lines.length; i++) {
            //lowercase the line to standardize on matching for 'prefix'
            var line = lines[i].toLowerCase();
            if (line.indexOf('prefix') != -1) {
                //parse the prefix from the line
                var prefix = line.split(':')[0].replace('prefix ', '');
                prefixes.push(prefix);
            }
        }
        
        //evaluate each prefix button to determine whether it exists in the array gathered from the textarea
        $('.prefix-button').each(function () {
            var prefix = $(this).text();
            //if the prefix is not in the array, unhide the button
            if (prefixes.indexOf(prefix) == -1) {
                $(this).parent('li').removeClass('hidden');
            } else {
                $(this).parent('li').addClass('hidden');
            }
        });
    });
    
    $('.prefix-button').click(function () {
        var uri = $(this).attr('uri');
        var prefix = $(this).text();
        var string = "PREFIX " + prefix + ":\t<" + uri + ">";
        
        //refresh CodeMirror with value
        
        //look for the line where the prefixes end
        var query = editor.getValue();
        var lines = query.split('\n');
        var lastPrefix = 0;
        
        for (var i = 0; i < lines.length; i++) {
            //lowercase the line to standardize on matching for 'prefix'
            var line = lines[i].toLowerCase();
            if (line.indexOf('prefix') != -1) {
                lastPrefix = i;
            }
        }
        
        //insert string into the new index
        lines.splice(lastPrefix + 1, 0, string);
        var newQuery = lines.join("\n");
        
        editor.setValue(newQuery);
        editor.refresh();
        return false;
    });
});