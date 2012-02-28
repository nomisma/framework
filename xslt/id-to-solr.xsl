<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times" xmlns:nm="http://nomisma.org/id/" xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:exsl="http://exslt.org/common" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:skos="http://www.w3.org/2008/05/skos#"
	xmlns:numishare="http://code.google.com/p/numishare/" xmlns:nuds="http://nomisma.org/id/nuds" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gml="http://www.opengis.net/gml/" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="/rdf:RDF"/>
		</add>
	</xsl:template>

	<xsl:template match="rdf:RDF">
		<doc>			
			<xsl:apply-templates select="skos:Concept"/>			
		</doc>
	</xsl:template>
	
	<xsl:template match="skos:Concept">
		<xsl:variable name="id" select="substring-after(@rdf:about, 'id/')"/>
		<field name="id">
			<xsl:value-of select="$id"/>
		</field>
		<field name="typeof">
			<xsl:value-of select="substring-after(skos:broader/@rdf:about, 'id/')"/>
		</field>
		<xsl:if test="string(skos:prefLabel[@xml:lang='en'][1])">
			<field name="prefLabel">
				<xsl:value-of select="skos:prefLabel[@xml:lang='en'][1]"/>
			</field>
		</xsl:if>
		<xsl:for-each select="skos:prefLabel[@xml:lang!='en']">
			<field name="altLabel">
				<xsl:value-of select="."/>
			</field>
		</xsl:for-each>
		<xsl:for-each select="skos:definition[not(@rdf:resource)]">
			<field name="definition">
				<xsl:value-of select="."/>
			</field>
		</xsl:for-each>
		<xsl:if test="skos:definition[string(@rdf:resource)]">
			<field name="object_uri">
				<xsl:value-of select="skos:definition/@rdf:resource"/>
			</field>
		</xsl:if>
		<xsl:for-each select="gml:pos">
			<field name="pos">
				<xsl:value-of select="."/>
			</field>
		</xsl:for-each>
		<xsl:for-each select="skos:related">
			<field name="related">
				<xsl:value-of select="@rdf:resource"/>
			</field>
			<xsl:if test="contains(@rdf:resource, 'pleiades')">
				<field name="pleiades_uri">
					<xsl:value-of select="@rdf:resource"/>
				</field>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="number(nm:approximateburialdate_start)">
			<field name="burial_start">
				<xsl:value-of select="nm:approximateburialdate_start"/>
			</field>
		</xsl:if>
		<xsl:if test="number(nm:approximateburialdate_end)">
			<field name="burial_start">
				<xsl:value-of select="nm:approximateburialdate_end"/>
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
		<field name="fulltext">
			<xsl:value-of select="$id"/>
			<xsl:text> </xsl:text>
			<xsl:for-each select="descendant-or-self::node()">
				<xsl:value-of select="text()"/>
				<xsl:text> </xsl:text>
			</xsl:for-each>
		</field>
	</xsl:template>


</xsl:stylesheet>
