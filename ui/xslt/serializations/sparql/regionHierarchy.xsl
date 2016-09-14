<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all"
	version="2.0">

	<xsl:param name="identifiers" select="tokenize(doc('input:request')/request/parameters/parameter[name='identifiers']/value, '\|')"/>

	<xsl:template match="/">
		<response>
			<xsl:apply-templates select="//res:sparql"/>
		</response>
	</xsl:template>

	<xsl:template match="res:sparql">
		<xsl:variable name="position" select="position()"/>
		<xsl:variable name="id" select="$identifiers[$position]"/>

		<hierarchy uri="http://nomisma.org/id/{$id}">
			<xsl:apply-templates select="descendant::res:result"/>
		</hierarchy>
	</xsl:template>

	<xsl:template match="res:result">
		<region uri="{res:binding[@name='uri']/res:uri}">
			<xsl:choose>
				<xsl:when test="string(res:binding[@name='lang']/res:literal)">
					<xsl:value-of select="res:binding[@name='lang']/res:literal"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="res:binding[@name='en']/res:literal"/>
				</xsl:otherwise>
			</xsl:choose>
		</region>
	</xsl:template>

</xsl:stylesheet>
