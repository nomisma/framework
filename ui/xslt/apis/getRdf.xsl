<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs xhtml" version="2.0">
	<xsl:include href="../serializations/xhtml/rdf-templates.xsl"/>

	<xsl:template match="/">
		<rdf:RDF xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:nm="http://nomisma.org/id/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
			<xsl:choose>
				<xsl:when test="child::xhtml:body">
					<xsl:apply-templates select="/xhtml:body/xhtml:div"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="xhtml:div"/>
				</xsl:otherwise>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>
