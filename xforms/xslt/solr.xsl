<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nuds="http://nomisma.org/id/nuds"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" media-type="text/xml" encoding="UTF-8"/>
	
	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="/xhtml:div"/>
		</add>
	</xsl:template>
	
	<xsl:template match="/xhtml:div">
		<doc>
			<xsl:variable name="id" select="@about"/>
			<field name="id">
				<xsl:value-of select="$id"/>
			</field>
			<field name="typeof">
				<xsl:value-of select="@typeof"/>
			</field>
			<xsl:if test="string(xhtml:div[@property='skos:prefLabel'][@xml:lang='en'][1])">
				<field name="prefLabel">
					<xsl:value-of select="xhtml:div[@property='skos:prefLabel'][@xml:lang='en'][1]"/>
				</field>
			</xsl:if>
			<xsl:for-each select="xhtml:div[@property='skos:prefLabel'][@xml:lang!='en']|xhtml:div[@property='skos:altLabel']">
				<field name="altLabel">
					<xsl:value-of select="."/>
				</field>
			</xsl:for-each>
			<xsl:for-each select="xhtml:div[@property='skos:definition']">
				<field name="definition">
					<xsl:value-of select="."/>
				</field>
			</xsl:for-each>			
			<!--<xsl:if test="count(descendant::*[@property='gml:pos']) = 1 or count(descendant::*[@property='nm:findspot']) = 1">
				<xsl:variable name="pos" select="if (string(descendant::*[@property='gml:pos'])) then tokenize(descendant::*[@property='gml:pos'], ' ') else tokenize(descendant::*[@property='nm:findspot'], ' ')"/>
				<field name="pos">
					<xsl:value-of select="if (string(descendant::*[@property='gml:pos'])) then descendant::*[@property='gml:pos'] else descendant::*[@property='nm:findspot']"/>
				</field>
				<field name="georef">
					<xsl:value-of select="concat('http://nomisma.org/id/', $id)"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="normalize-space(xhtml:div[@property='skos:prefLabel'][@xml:lang='en'][1])"/>
					<xsl:text>|</xsl:text>
					<xsl:value-of select="$pos[2]"/>
					<xsl:text>,</xsl:text>
					<xsl:value-of select="$pos[1]"/>
				</field>
			</xsl:if>-->
			<xsl:for-each select="xhtml:div[@property='skos:related']">
				<field name="related">
					<xsl:value-of select="@resource"/>
				</field>
				<xsl:if test="contains(@resource, 'pleiades')">
					<field name="pleiades_uri">
						<xsl:value-of select="@resource"/>
					</field>
				</xsl:if>
			</xsl:for-each>
			<field name="timestamp">
				<xsl:variable name="timestamp" select="datetime:dateTime()"/>
				<xsl:choose>
					<xsl:when test="contains($timestamp, 'Z')">
						<xsl:value-of select="$timestamp"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($timestamp, 'Z')"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
			<field name="fulltext">
				<xsl:value-of select="$id"/>
				<xsl:text> </xsl:text>
				<xsl:for-each select="descendant-or-self::node()">
					<xsl:value-of select="text()"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</field>
		</doc>
	</xsl:template>
</xsl:stylesheet>