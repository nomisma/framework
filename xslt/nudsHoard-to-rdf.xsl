<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:gml="http://www.opengis.net/gml/" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	
	<!-- url -->
	<xsl:variable name="url">http://localhost:8080/orbeon/nomisma/</xsl:variable>
	
	<xsl:template match="/">
		<xsl:apply-templates select="nh:nudsHoard"/>
	</xsl:template>

	<xsl:template match="nh:nudsHoard">
		<xsl:variable name="id" select="nh:nudsHeader/nh:nudsid"/>
		<rdf:RDF xmlns:nm="http://nomisma.org/id/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
			xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:gml="http://www.opengis.net/gml/">
			<skos:Concept rdf:about="{$url}id/{$id}">
				<skos:broader rdf:about="{$url}id/hoard"/>
				<skos:prefLabel xml:lang="en">
					<xsl:value-of select="$id"/>
				</skos:prefLabel>
				<skos:definition rdf:resource="{$url}xml/{$id}"/>
			</skos:Concept>
		</rdf:RDF>
	</xsl:template>

</xsl:stylesheet>
