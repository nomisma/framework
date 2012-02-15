<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:gml="http://www.opengis.net/gml/" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<xsl:apply-templates select="nuds:nuds"/>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<xsl:variable name="id" select="nuds:nudsHeader/nuds:nudsid"/>
		<rdf:RDF xmlns:nm="http://nomisma.org/id/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
			xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:gml="http://www.opengis.net/gml/">
			<skos:Concept rdf:about="http://nomisma.org/id/{$id}">
				<skos:broader rdf:about="http://nomisma.org/id/type_series_item"/>
				<skos:prefLabel xml:lang="en">
					<xsl:value-of select="nuds:descMeta/nuds:title"/>
				</skos:prefLabel>
				<skos:definition rdf:resource="http://nomisma.org/id/{$id}.xml"/>
			</skos:Concept>
		</rdf:RDF>
	</xsl:template>

</xsl:stylesheet>
