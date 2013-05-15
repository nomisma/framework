$(document).ready(function () {
	//links (from original nomisma.js
	
	
	var lArr = $('[rel]');
	
	for (i = 0; lArr.length >= i; i++) {
		if (lArr[i]) {
			if (tmp = lArr[i].getAttribute('resource')) {
				oldhtml = lArr[i].innerHTML;
				newhtml = "<a target='_new' href='http://nomisma.org/id/" + tmp + "'><img src='http://upload.wikimedia.org/wikipedia/commons/6/64/Icon_External_Link.png'/></a>" + oldhtml;
				lArr[i].innerHTML = newhtml;
			};
		};
	}
	
	
	var lArr = $('[property]');
	
	for (i = 0; lArr.length >= i; i++) {
		if (lArr[i]) {
			if (tmp = lArr[i].getAttribute('resource')) {
				var pleiades = tmp.match(/pleiades.stoa.org/)? "<a target='_blank' href='http://numismatics.org/search/results?q=pleiades_uri%3A%22" + tmp + "%22+AND+imagesavailable%3Atrue'><img src='http://numismatics.org/search/images/favicon.png'/></a>": '';
				tmp = tmp.match(/^http:/)? tmp: 'http://nomisma.org/id/' + tmp;
				var oldhtml = lArr[i].innerHTML;
				var newhtml = "<a target='_new' href='" + tmp + "'><img src='http://upload.wikimedia.org/wikipedia/commons/6/64/Icon_External_Link.png'/></a> " + pleiades + oldhtml;
				lArr[i].innerHTML = newhtml;
			};
		};
	}
	
	var lArr = $('[typeof]');
	
	for (i = 0; lArr.length >= i; i++) {
		if (lArr[i]) {
			if (tmp = lArr[i].getAttribute('typeof')) {
				if (tmp == 'rdfs:Resource') {
					tmp = 'http://www.w3.org/TR/rdf-schema/#ch_resource'
				}
				oldhtml = lArr[i].innerHTML;
				newhtml = "<a target='_new' href='http://nomisma.org/id/" + tmp + "'><img src='http://upload.wikimedia.org/wikipedia/commons/6/64/Icon_External_Link.png'/></a>" + oldhtml;
				lArr[i].innerHTML = newhtml;
			};
		};
	}
});