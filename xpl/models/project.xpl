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
		<p:input name="data" href="../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:variable name="project" select="tokenize(substring-after(doc('input:request')/request/request-url, 'project/'), '/')[1]"/>
				<xsl:variable name="id" select="tokenize(substring-after(doc('input:request')/request/request-url, 'project/'), '/')[2]"/>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql"/>
				<xsl:variable name="query">
					<xsl:choose>
						<xsl:when test="string-length($project) &gt; 0"><![CDATA[ PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>
PREFIX void:	<http://rdfs.org/ns/void#>

SELECT ?project ?title ?description ?license ?uriSpace  WHERE {
?project rdfs:seeAlso <http://nomisma.org/project/PROJECT/> .
?project dcterms:title ?title .
?project  dcterms:description ?description .
?project dcterms:license ?license .
?project void:uriSpace ?uriSpace}]]></xsl:when>
						<xsl:otherwise><![CDATA[ PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>
PREFIX void:	<http://rdfs.org/ns/void#>

SELECT ?project ?seeAlso ?title ?description ?license ?uriSpace  WHERE {
?project a void:dataSet .
?project rdfs:seeAlso ?seeAlso .
?project dcterms:title ?title .
?project  dcterms:description ?description .
?project dcterms:license ?license .
?project void:uriSpace ?uriSpace}]]></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="service">
					<xsl:choose>
						<xsl:when test="string-length($project) &gt; 0">
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'PROJECT', $project)), '&amp;output=xml')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri($query), '&amp;output=xml')"/>
						</xsl:otherwise>
					</xsl:choose>					
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
