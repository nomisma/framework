<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:ecrm="http://erlangen-crm.org/current/" xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#"
	exclude-result-prefixes="xsl xs" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="rdf:RDF">
		<rdf:RDF>
			<xsl:apply-templates/>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="nm:nomisma_region|nm:head_1911_region">
		<nm:region>
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

	<xsl:template match="nm:mint[descendant::geo:lat]|nm:region[descendant::geo:lat]">
		<xsl:element name="{name()}" namespace="http://nomisma.org/id/">
			<xsl:apply-templates select="@*|*[not(name()='nm:uncertain_value') and not(name()='geo:lat') and not(name()='geo:long')]"/>
			<geo:location rdf:resource="{concat(@rdf:about, '#this')}"/>
		</xsl:element>
		<geo:spatialThing rdf:about="{concat(@rdf:about, '#this')}">
			<xsl:if test="descendant::geo:lat">
				<geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float">
					<xsl:value-of select="descendant::geo:lat"/>
				</geo:lat>
			</xsl:if>
			<xsl:if test="descendant::geo:long">
				<geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float">
					<xsl:value-of select="descendant::geo:long"/>
				</geo:long>
			</xsl:if>
			<xsl:if test="nm:uncertain_value">
				<un:hasUncertainty rdf:resource="http://nomisma.org/id/uncertain_value"/>
			</xsl:if>
		</geo:spatialThing>
	</xsl:template>

</xsl:stylesheet>
