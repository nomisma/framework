<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:bio="http://purl.org/vocab/bio/0.1/" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:nm="http://nomisma.org/id/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:prov="http://www.w3.org/ns/prov#"
	xmlns:rdac="http://www.rdaregistry.info/Elements/c/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" exclude-result-prefixes="xsl xs"
	version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="dcterms:ProvenanceStatement">
		<dcterms:ProvenanceStatement>
			<xsl:attribute name="rdf:about" select="concat(foaf:topic/@rdf:resource, '#provenance')"/>

			<xsl:apply-templates/>
		</dcterms:ProvenanceStatement>
	</xsl:template>
</xsl:stylesheet>
