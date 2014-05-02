<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsl xs" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:dc="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:foaf="http://xmlns.com/foaf/0.1/" version="2.0">
	<xsl:variable name="id-path" select="/config/id_path"/>
	<xsl:param name="identifiers" select="doc('input:request')/request/parameters/parameter[name='identifiers']/value"/>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:for-each select="tokenize($identifiers, '\|')">
				<xsl:if test="doc-available(concat('file://', $id-path, '/', ., '.xml'))">
					<xsl:copy-of select="document(concat('file://', $id-path, '/', ., '.xml'))/rdf:RDF/*"/>
				</xsl:if>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:template>

</xsl:stylesheet>
