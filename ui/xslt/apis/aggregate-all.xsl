<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsl xs" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:foaf="http://xmlns.com/foaf/0.1/" version="2.0">
	<xsl:strip-space elements="*"/>
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	
	<xsl:template match="/">
		<xsl:variable name="collection" select="concat('file://', /config/id_path, '/?select=*.xml')"/>
		<rdf:RDF>
			<xsl:for-each select="collection($collection)">
				<xsl:copy-of select="document(document-uri(.))/rdf:RDF/*"/>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>
