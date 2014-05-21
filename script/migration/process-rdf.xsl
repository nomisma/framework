<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:ecrm="http://erlangen-crm.org/current/" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="nm:nomisma_region|nm:head_1911_region">
		<nm:region rdf:about="{@rdf:about}">
			<xsl:apply-templates select="@*|node()"/>
		</nm:region>
	</xsl:template>
	
	<xsl:template match="skos:related">
		<xsl:variable name="uri" select="@rdf:resource"/>
		
		<xsl:choose>
			<xsl:when test="contains($uri, 'pleiades')">
				<skos:relatedMatch rdf:resource="{$uri}"/>
			</xsl:when>
			<xsl:when test="contains($uri, 'wikipedia')">
				<xsl:variable name="pieces" select="tokenize($uri, '/')"/>
				
				<skos:exactMatch rdf:resource="http://dbpedia.org/resource/{$pieces[last()]}"/>
			</xsl:when>
			<xsl:otherwise>
				<skos:exactMatch rdf:resource="{$uri}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
