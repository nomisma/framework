<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:nomisma="http://nomisma.org/" xmlns:math="http://exslt.org/math" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- URL parameters -->
	<xsl:param name="url" select="doc('input:config-xml')/config/url"/>

	<xsl:template match="/">
		<!-- construct an object that conforms to JSend JSON response format: https://github.com/omniti-labs/jsend -->
		<xsl:variable name="model" as="element()*">
			<_object>
				<status>success</status>
				<data>
					<_object>
						<dieStudies>
							<_array>
								<xsl:apply-templates select="descendant::res:result"/>
							</_array>
						</dieStudies>
						<formulas>
							<_array>
								<xsl:apply-templates select="doc('input:config-xml')//dieStudy_formulas/formula"/>
							</_array>
						</formulas>
					</_object>
				</data>			
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:variable name="type" select="res:binding[@name = 'exampleType']/res:uri"/>
		<xsl:variable name="dieStudy" select="res:binding[@name = 'dieStudy']/res:uri"/>
		
		<_object>
			<xsl:apply-templates select="res:binding"/>

			<!-- create URL pattern for each formula and  -->
			<examples>
				<_array>
					<xsl:for-each select="doc('input:config-xml')//dieStudy_formulas/formula">
						<_>
							<xsl:value-of select="concat($url, 'apis/', id, '?dieStudy=', encode-for-uri($dieStudy), '&amp;type=', encode-for-uri($type))"/>
						</_>
					</xsl:for-each>
				</_array>
			</examples>

		</_object>


	</xsl:template>

	<xsl:template match="res:binding">
		<xsl:element name="{@name}">
			<xsl:value-of select="
					if (res:literal) then
						res:literal
					else
						res:uri"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="formula">
		<_object>
			<title>
				<xsl:value-of select="title"/>
			</title>
			<reference>
				<xsl:value-of select="reference"/>
			</reference>
			<url>
				<xsl:value-of select="concat($url, '/', id)"/>
			</url>
		</_object>
	</xsl:template>

</xsl:stylesheet>
