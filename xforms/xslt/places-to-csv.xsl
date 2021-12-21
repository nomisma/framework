<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: December 2021
	Function: Serialize XML instance for place URIs that do not map to Wikidata entities into a CSV file for download	
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="/">
		<xsl:text>"Label","URI"</xsl:text>		
		<xsl:text>&#x0A;</xsl:text>
		<xsl:apply-templates select="//warning"/>
	</xsl:template>

	<xsl:template match="warning">
		<xsl:value-of select="concat('&#x022;', @label, '&#x022;')"/>
		<xsl:text>,</xsl:text>
		<xsl:value-of select="concat('&#x022;', @uri, '&#x022;')"/>
		<xsl:text>&#x0A;</xsl:text>		
	</xsl:template>
</xsl:stylesheet>
