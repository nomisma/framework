<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs xhtml" version="2.0">
	<xsl:include href="../display/templates.xsl"/>

	<xsl:param name="id-path"/>
	<xsl:param name="identifiers"/>

	<xsl:variable name="content" as="element()*">
		<content xmlns="http://www.w3.org/1999/xhtml">
			<xsl:for-each select="tokenize($identifiers, '\|')">
				<xsl:if test="doc-available(concat($id-path, '/', ., '.txt'))">
					<xsl:copy-of select="document(concat($id-path, '/', ., '.txt'))/*"/>
				</xsl:if>				
			</xsl:for-each>
		</content>
	</xsl:variable>

	<xsl:template match="/">
		<!--		<xsl:copy-of select="$content"/>-->
		<rdf:RDF xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:nm="http://nomisma.org/id/" xmlns:cc="http://creativecommons.org/ns#"
			xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
			<xsl:apply-templates select="$content/xhtml:div"/>
		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>
