<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date July 2022
	Function: Execute a SPARQL query to get a list of die studies (sd:namedGraph) and the associated type series
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				
				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>

				<xsl:variable name="query"><![CDATA[PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:  <http://nomisma.org/id/>
PREFIX nmo:  <http://nomisma.org/ontology#>
PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos:  <http://www.w3.org/2004/02/skos/core#>
PREFIX sd:	<http://www.w3.org/TR/sparql11-service-description/>
PREFIX void:	<http://rdfs.org/ns/void#>

SELECT DISTINCT ?dieStudy ?typeSeries ?dataset ?datasetTitle (sample(?type) as ?exampleType) WHERE {
  ?subject sd:namedGraph/sd:name ?dieStudy .
  GRAPH ?dieStudy {
    ?coin a nmo:NumismaticObject             
  }  
  ?coin nmo:hasTypeSeriesItem ?type .  
  ?type dcterms:source ?typeSeries ;
        void:inDataset ?dataset .
  ?dataset dcterms:title ?datasetTitle .
} GROUP BY ?dieStudy ?typeSeries ?dataset ?datasetTitle]]></xsl:variable>
				
				<xsl:variable name="service">
					<xsl:value-of
						select="concat($sparql_endpoint, '?query=', encode-for-uri($query), '&amp;output=xml')"/>
				</xsl:variable>

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
