<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="/div"/>
		</add>
	</xsl:template>

	<xsl:template match="div">
		<xsl:variable name="id" select="translate(replace(@about, 'nm:', ''), '[]', '')"/>

		<doc>
			<field name="id">
				<xsl:value-of select="$id"/>
			</field>
			<field name="typeof">
				<xsl:value-of select="translate(replace(@typeof, 'nm:', ''), '[]', '')"/>
			</field>
			<xsl:if test="string(div[@property='skos:prefLabel'])">
				<field name="prefLabel">
					<xsl:value-of select="div[@property='skos:prefLabel']"/>
				</field>
			</xsl:if>
			<xsl:for-each select="//span[@property='skos:altLabel']">
				<field name="altLabel">
					<xsl:value-of select="."/>
				</field>
			</xsl:for-each>
			<xsl:for-each select="//div[@property='skos:definition']">
				<field name="definition">
					<xsl:value-of select="."/>
				</field>
			</xsl:for-each>
			<xsl:for-each select="//*[@property='gml:pos']">
				<field name="pos">
					<xsl:value-of select="."/>
				</field>
			</xsl:for-each>
			<xsl:for-each select="//*[@rel='skos:related']">
				<field name="related">
					<xsl:value-of select="@href"/>
				</field>
				<xsl:if test="contains(@href, 'pleiades')">
					<field name="pleiades_uri">
						<xsl:value-of select="@href"/>
					</field>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="number(//*[@property='nm:approximateburialdate_start']/@content)">
				<field name="burial_start">
					<xsl:value-of select="//*[@property='nm:approximateburialdate_start']/@content"/>
				</field>
			</xsl:if>
			<xsl:if test="number(//*[@property='nm:approximateburialdate_end']/@content)">
				<field name="burial_end">
					<xsl:value-of select="//*[@property='nm:approximateburialdate_end']/@content"/>
				</field>
			</xsl:if>
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
			<xsl:if test="$id != 'findspot'">
				<field name="fulltext">
					<xsl:value-of select="$id"/>
					<xsl:text> </xsl:text>
					<xsl:for-each select="descendant-or-self::node()">
						<xsl:value-of select="text()"/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</field>
			</xsl:if>
		</doc>
	</xsl:template>


</xsl:stylesheet>
