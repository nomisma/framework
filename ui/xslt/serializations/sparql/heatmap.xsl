<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="xs"
	version="2.0">

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="count(descendant::res:result) &gt; 0">
				<xsl:text>{"max":1</xsl:text>
				<xsl:text>,"data":[</xsl:text>
				<xsl:apply-templates select="descendant::res:result"/>
				<xsl:text>]}</xsl:text>
			</xsl:when>
			<xsl:otherwise>{}</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="res:result">
		<xsl:value-of select="concat('{&#x022;lat&#x022;:', res:binding[@name='lat']/res:literal, ', &#x022;lng&#x022;:', res:binding[@name='long']/res:literal, ', &#x022;count&#x022;:',1, '}')"/>
		<xsl:if test="not(position()=last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
