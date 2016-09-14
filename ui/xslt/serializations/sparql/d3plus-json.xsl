<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name='dist']/value"/>
	<xsl:param name="filter" select="doc('input:request')/request/parameters/parameter[name='filter']/value"/>

	<xsl:template match="/">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates select="descendant::res:result"/>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:variable name="object" as="element()*">
			<row>
				<xsl:element name="subset">
					<xsl:value-of select="nomisma:parseFilter($filter)"/>
				</xsl:element>
				<xsl:element name="{lower-case(substring-after($dist, 'has'))}">
					<xsl:value-of select="res:binding[@name='label']/res:literal"/>
				</xsl:element>
				<xsl:element name="count">
					<xsl:value-of select="res:binding[@name='count']/res:literal"/>
				</xsl:element>
			</row>			
		</xsl:variable>
		
		<xsl:text>{</xsl:text>
		<xsl:for-each select="$object/*">
			<xsl:value-of select="concat('&#x022;', name(), '&#x022;')"/>
			<xsl:text>:</xsl:text>
			<xsl:choose>
				<xsl:when test=". castable as xs:integer">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('&#x022;', ., '&#x022;')"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not(position()=last())">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>}</xsl:text>
		<xsl:if test="not(position()=last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:function name="nomisma:parseFilter">
		<xsl:param name="query"/>
		
		<xsl:variable name="pieces" select="tokenize(normalize-space($query), ';')"/>
		
		<xsl:for-each select="$pieces">
			<xsl:analyze-string select="."
				regex="nmo:has([A-Za-z]+)\snm:(.*)">				
				<xsl:matching-substring>
					<xsl:value-of select="regex-group(1)"/>
					<xsl:text>-</xsl:text>
					<xsl:value-of select="regex-group(2)"/>
				</xsl:matching-substring>				
			</xsl:analyze-string>
			<xsl:if test="not(position()=last())">
				<xsl:text> &amp; </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
</xsl:stylesheet>
