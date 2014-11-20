<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="/rdf:RDF/geo:SpatialThing"/>
		</add>
	</xsl:template>

	<xsl:template match="geo:SpatialThing">
		<xsl:variable name="uri" select="@rdf:about"/>

		<doc>
			<field name="uri">
				<xsl:value-of select="$uri"/>
			</field>
			<xsl:choose>
				<xsl:when test="geo:lat and geo:long">
					<field name="geo">
						<xsl:value-of select="geo:long"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="geo:lat"/>
					</field>
				</xsl:when>
			</xsl:choose>
		</doc>
	</xsl:template>
</xsl:stylesheet>
