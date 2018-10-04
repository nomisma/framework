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
		<xsl:variable name="element" select="if (res:binding[@name='type']/res:uri = 'http://nomisma.org/ontology#Mint') then 'mint' else 'region'"/>
		
		<xsl:element name="{$element}">
			<xsl:attribute name="uri" select="res:binding[@name='uri']/res:uri"/>
			
			<!-- optional coordinates -->
			<xsl:if test="res:binding[@name='lat']">
				<xsl:attribute name="lat" select="res:binding[@name='lat']/res:literal"/>
			</xsl:if>
			<xsl:if test="res:binding[@name='long']">
				<xsl:attribute name="long" select="res:binding[@name='long']/res:literal"/>
			</xsl:if>
			
			<xsl:choose>
				<xsl:when test="string(res:binding[@name='lang']/res:literal)">
					<xsl:value-of select="res:binding[@name='lang']/res:literal"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="res:binding[@name='en']/res:literal"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
