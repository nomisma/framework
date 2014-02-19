<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="templates.xsl"/>

	<xsl:variable name="display_path"/>
	<xsl:variable name="default-query">
		<![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX owl:	<http://www.w3.org/2002/07/owl#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX ecrm:	<http://erlangen-crm.org/current/>
PREFIX geo:	<http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX xsd:	<http://www.w3.org/2001/XMLSchema#>

SELECT * WHERE {
?s ?p ?o
}]]>
	</xsl:variable>

	<xsl:template match="/">
		<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml"
			prefix="nm: http://nomisma.org/id/
			dcterms: http://purl.org/dc/terms/
			foaf: http://xmlns.com/foaf/0.1/
			geo:  http://www.w3.org/2003/01/geo/wgs84_pos#
			owl:  http://www.w3.org/2002/07/owl#
			rdfs: http://www.w3.org/2000/01/rdf-schema#
			rdfa: http://www.w3.org/ns/rdfa#
			rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
			skos: http://www.w3.org/2004/02/skos/core#"
			vocab="http://nomisma.org/id/">
			<head>
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/>
				<title>Nomisma SPARQL Interface</title>
				<style type="text/css">
					@import url(<xsl:value-of select="concat($display_path, 'style.css')"/>
					);</style>
				<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"/>
				<script type="text/javascript">
					$(document).ready(function(){
						$('#toggle-examples').click(function(){
							$('#examples').toggle();
							return false;
						});
						
					});
				</script>
			</head>
			<body>
	
				<xsl:call-template name="header"/>

				<div class="center">
					<h1>SPARQL Query</h1>
					<form action="query" method="GET" accept-charset="UTF-8">
						<textarea name="query" rows="20" style="width:95%">
							<xsl:value-of select="$default-query"/>
						</textarea>
						<br/> Output: <select name="output">
							<option value="json">JSON</option>
							<option value="xml">XML</option>
							<option value="text">Text</option>
							<option value="csv">CSV</option>
							<option value="tsv">TSV</option>
						</select>
						<br/> XSLT style sheet (blank for none): <input name="stylesheet" size="20" value="/xml-to-html.xsl"/>
						<br/>
						<!--<input type="checkbox" name="force-accept" value="text/plain"/>
						Force the accept header to <tt>text/plain</tt> regardless 
						<br/>-->
						<input type="submit" value="Get Results"/>
					</form>
					<h3><a href="#" id="toggle-examples">Hide/show example queries</a></h3>
					<div id="examples" style="display:none">
						<div>
							<b>Get all weights of Augustan denarii</b><br/>
							<pre><![CDATA[
PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
SELECT ?type ?weight WHERE {
?type nm:authority <http://nomisma.org/id/augustus> .
?type nm:denomination <http://nomisma.org/id/denarius> .
?type dcterms:isPartOf <http://nomisma.org/id/ric>.
?coin nm:type_series_item ?type .
?coin nm:weight ?weight 
}]]>
							</pre>
						</div>
						<div>
							<b>Get coins of RIC Augustus 1A and 1B</b><br/>
							<pre><![CDATA[
PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
SELECT ?object ?objectType ?publisher ?weight ?axis ?obvThumb ?revThumb ?obvRef ?revRef ?findspot ?type  WHERE {
{?object nm:type_series_item <http://numismatics.org/ocre/id/ric.1(2).aug.1A>. }
UNION { ?object nm:type_series_item <http://numismatics.org/ocre/id/ric.1(2).aug.1B> }
?object rdf:type ?objectType .
OPTIONAL { ?object dcterms:publisher ?publisher } .
OPTIONAL { ?object nm:weight ?weight }
OPTIONAL { ?object nm:axis ?axis }
OPTIONAL { ?object nm:obverseThumbnail ?obvThumb }
OPTIONAL { ?object nm:reverseThumbnail ?revThumb }
OPTIONAL { ?object nm:obverseReference ?obvRef }
OPTIONAL { ?object nm:reverseReference ?revRef }
}]]>
							</pre>
						</div>
						<div>
							<b>Average weight of RIC Augustus 1A</b><br/>
							<pre><![CDATA[
PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX xsd:	<http://www.w3.org/2001/XMLSchema#>
SELECT (AVG(xsd:decimal(?weight)) AS ?average)
WHERE {
?g nm:type_series_item <http://numismatics.org/ocre/id/ric.1(2).aug.1A>.
?g nm:weight ?weight
}]]>
							</pre>
						</div>
						<div>
							<b>Average diameter of RIC Augustus 1A</b><br/>
							<pre><![CDATA[
PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX xsd:	<http://www.w3.org/2001/XMLSchema#>
SELECT (AVG(xsd:decimal(?weight)) AS ?average)
WHERE {
?g nm:type_series_item <http://numismatics.org/ocre/id/ric.1(2).aug.1A>.
?g nm:diameter ?diameter
}]]>
							</pre>
						</div>
						<div>
							<b>Get all findspots for coins minted in Rome, where the mint is defined explicitly or implicitly through the coin type.</b><br/>
							<pre><![CDATA[
PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
SELECT DISTINCT ?object ?findspot ?lat ?long ?title ?prefLabel WHERE {
{?type nm:mint <http://nomisma.org/id/rome> .
?object nm:type_series_item ?type.
?object nm:findspot ?findspot .
?findspot geo:lat ?lat .
?findspot geo:long ?long
}
UNION {
?object nm:mint <http://nomisma.org/id/rome> .
?object nm:findspot ?findspot .
?findspot geo:lat ?lat .
?findspot geo:long ?long
}
OPTIONAL {?object skos:prefLabel ?prefLabel}
OPTIONAL {?object dcterms:title ?title}
}]]>
							</pre>
						</div>
						<div>
							<b>Get all findspots for RIC Augustus 1A</b><br/>
							<pre><![CDATA[
PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
SELECT ?object ?findspot ?lat ?long ?title ?prefLabel WHERE {
?object nm:type_series_item <http://numismatics.org/ocre/id/ric.1(2).aug.1A> .
?object nm:findspot ?findspot .
?findspot geo:lat ?lat .
?findspot geo:long ?long .
OPTIONAL {?object skos:prefLabel ?prefLabel}
OPTIONAL {?object dcterms:title ?title}
}]]>
							</pre>
						</div>
					</div>
				</div>

				<!-- footer -->
				<xsl:call-template name="footer"/>

			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
