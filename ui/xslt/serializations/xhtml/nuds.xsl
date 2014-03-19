<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xhtml xsl xs"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:gml="http://www.opengis.net/gml/" version="2.0">
	<xsl:include href="nuds-templates.xsl"/>
	
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="mode">single</xsl:param>
	
	<xsl:variable name="rdf" as="element()*">
		<xsl:copy-of select="/content/rdf:RDF"/>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/xhtml:div"/>
	</xsl:template>

</xsl:stylesheet>
