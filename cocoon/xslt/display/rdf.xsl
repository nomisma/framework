<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xhtml xsl xs" xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:nm="http://nomisma.org/id/" xmlns:cc="http://creativecommons.org/ns#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" version="2.0">
	<xsl:output indent="yes" omit-xml-declaration="yes"/>
	<xsl:include href="templates.xsl"/>

	<xsl:template match="/">
		<rdf:RDF xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:nm="http://nomisma.org/id/" xmlns:cc="http://creativecommons.org/ns#"
			xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
			<xsl:apply-templates select="descendant::*[string(@about)]"/>
		</rdf:RDF>
	</xsl:template>

</xsl:stylesheet>
