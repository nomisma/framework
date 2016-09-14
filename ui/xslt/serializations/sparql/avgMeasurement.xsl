<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:param name="api" select="substring-after(doc('input:request')/request/request-url, 'apis/')"/>
	<xsl:param name="format" select="doc('input:request')/request/parameters/parameter[name='format']/value"/>
	<xsl:variable name="measurement" select="lower-case(substring-after($api, 'avg'))"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$format='json'">
				<xsl:text>{"</xsl:text>
				<xsl:value-of select="$measurement"/>
				<xsl:text>":</xsl:text>
				<xsl:value-of select="number(descendant::res:binding[@name='average']/res:literal)"/>
				<xsl:text>}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<response>
					<xsl:value-of select="number(descendant::res:binding[@name='average']/res:literal)"/>
				</response>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
