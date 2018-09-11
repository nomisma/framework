<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsl xs"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#"
	xmlns:rdac="http://www.rdaregistry.info/Elements/c/" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:org="http://www.w3.org/ns/org#" xmlns:bio="http://purl.org/vocab/bio/0.1/" xmlns:prov="http://www.w3.org/ns/prov#" version="2.0">
	<xsl:strip-space elements="*"/>
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

	<xsl:template match="/">
		<xsl:variable name="collection" select="concat('file://', /config/data_path, '?select=*.rdf;recurse=yes')"/>
		<rdf:RDF>
			<xsl:for-each select="collection($collection)">
				<xsl:copy-of select="document(document-uri(.))/rdf:RDF/*"/>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:template>

</xsl:stylesheet>
