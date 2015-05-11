<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
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
				
				<xsl:variable name="query"><![CDATA[ PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>
PREFIX void:	<http://rdfs.org/ns/void#>

SELECT ?dataset ?title ?description ?publisher ?license ?dump ?count WHERE {
?dataset a void:Dataset ; 
 dcterms:title ?title ; 
 dcterms:description ?description ; 
 dcterms:publisher ?publisher ; 
 dcterms:license ?license ; 
 void:dataDump ?dump 
 { SELECT ?dataset ( count(?object) as ?count ) { ?object void:inDataset ?dataset } GROUP BY ?dataset }
 } ORDER BY ASC(?publisher) ASC(?title)]]>
				</xsl:variable>

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
