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
				<!-- request parameters -->
				<xsl:param name="identifiers" select="doc('input:request')/request/parameters/parameter[name='identifiers']/value"/>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
				
				<xsl:variable name="query">
					<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX nmo:	<http://nomisma.org/ontology#>
			PREFIX owl:      <http://www.w3.org/2002/07/owl#>
			PREFIX xsd:	<http://www.w3.org/2001/XMLSchema#>
			SELECT (MAX(xsd:int(?date)) AS ?year)
			WHERE {
			<IDENTIFIERS>
			}
			]]>
				</xsl:variable>
				
				<xsl:variable name="replace">
					<xsl:for-each select="tokenize($identifiers, '\|')">
						<xsl:choose>
							<xsl:when test="position() = 1">
								<xsl:text>{&lt;</xsl:text>
								<xsl:value-of select="."/>
								<xsl:text>&gt; nmo:hasEndDate ?date }</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>UNION {&lt;</xsl:text>
								<xsl:value-of select="."/>
								<xsl:text>&gt; nmo:hasEndDate ?date }</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>

				<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, '&lt;IDENTIFIERS&gt;', $replace))), '&amp;output=xml')"/>
				
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
