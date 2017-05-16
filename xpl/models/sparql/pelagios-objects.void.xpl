<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
				<xsl:variable name="query"><![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX void: <http://rdfs.org/ns/void#>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>

SELECT DISTINCT ?dataset ?title ?description ?license ?rights ?publisher WHERE {
?coin a nmo:NumismaticObject ;
        void:inDataset ?dataset . FILTER (?dataset != <http://numismatics.org/search/> && ?dataset != <http://coins.lib.virginia.edu/> && ?dataset != <https://finds.org.uk/>) .
?dataset dcterms:description ?description FILTER (langMatches(lang(?description), "en") || lang(?description) = "") .
?dataset dcterms:publisher ?publisher ;
         dcterms:title ?title FILTER (langMatches(lang(?title), "en") || lang(?title) = "")
OPTIONAL {?dataset dcterms:rights ?rights}
OPTIONAL {?dataset dcterms:license ?license}
}]]></xsl:variable>

				<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri($query), '&amp;output=xml')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
