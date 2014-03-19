<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:nm="http://nomisma.org/id/" exclude-result-prefixes="xhtml xsl xs nm rdf rdfa skos" version="2.0">
	<xsl:include href="../serializations/xhtml/nuds-templates.xsl"/>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="mode">apis</xsl:param>

	<xsl:variable name="rdf" as="element()*">
		<xsl:copy-of select="/content/rdf:RDF"/>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="count(/content/xhtml:body/xhtml:div) = 1">
				<xsl:apply-templates select="/content/xhtml:body/xhtml:div"/>
			</xsl:when>
			<xsl:when test="count(/content/xhtml:body/xhtml:div) &gt; 1">
				<nudsGroup xmlns="http://nomisma.org/nuds" xmlns:xlink="http://www.w3.org/1999/xlink">
					<xsl:apply-templates select="/content/xhtml:body/xhtml:div"/>
				</nudsGroup>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
