<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all" version="2.0">

	<xsl:include href="solr-templates.xsl"/>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="/rdf:RDF/*" mode="generateDoc"/>
		</add>
	</xsl:template>
</xsl:stylesheet>
