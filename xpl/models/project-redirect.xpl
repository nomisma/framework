<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>

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
				<xsl:variable name="query"><![CDATA[ PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX owl:	<http://www.w3.org/2002/07/owl#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX ecrm:	<http://erlangen-crm.org/current/>
PREFIX geo:	<http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX xsd:	<http://www.w3.org/2001/XMLSchema#>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>
PREFIX void:	<http://rdfs.org/ns/void#>

SELECT ?project ?title ?description ?license ?uriSpace  WHERE {
?project rdfs:seeAlso <http://nomisma.org/project/PROJECT/> .
?project dcterms:title ?title .
?project  dcterms:description ?description .
?project dcterms:license ?license .
?project void:uriSpace ?uriSpace}]]>
				</xsl:variable>

				<xsl:variable name="service">
					<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'PROJECT', $project)), '&amp;output=xml')"/>
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
		<p:output name="data" id="model"/>
	</p:processor>

	<!-- serialize it -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:res="http://www.w3.org/2005/sparql-results#">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="project" select="tokenize(substring-after(doc('input:request')/request/request-url, 'project/'), '/')[1]"/>
					<xsl:variable name="id" select="tokenize(substring-after(doc('input:request')/request/request-url, 'project/'), '/')[2]"/>


					<html xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<head/>
						<body>
							<p>See other: <xsl:value-of select="concat(//res:binding[@name='uriSpace']/res:literal, $id)"/></p>
						</body>
					</html>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="body"/>
	</p:processor>

	<!-- generate config for http-serializer -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:res="http://www.w3.org/2005/sparql-results#">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="project" select="tokenize(substring-after(doc('input:request')/request/request-url, 'project/'), '/')[1]"/>
					<xsl:variable name="id" select="tokenize(substring-after(doc('input:request')/request/request-url, 'project/'), '/')[2]"/>
					<config>
						<status-code>303</status-code>
						<content-type>text/plain</content-type>
						<header>
							<name>Location</name>
							<value>
								<xsl:value-of select="concat(//res:binding[@name='uriSpace']/res:literal, $id)"/>
							</value>
						</header>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="head"/>
	</p:processor>

	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#body"/>
		<p:input name="config" href="#head"/>
	</p:processor>
</p:config>
