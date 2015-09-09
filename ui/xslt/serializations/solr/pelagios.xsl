<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:lawd="http://lawd.info/ontology/" xmlns:void="http://rdfs.org/ns/void#"
	exclude-result-prefixes="xsl xs" version="2.0">

	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="//doc"/>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="doc">
		<lawd:Place rdf:about="http://nomisma.org/id/{str[@name='id']}">
			<rdfs:label>Apollonia Salbace</rdfs:label>
			<xsl:for-each select="distinct-values(arr[@name='pleiades_uri']/str)">
				<skos:closeMatch rdf:resource="{.}#this"/>
			</xsl:for-each>
			<void:inDataset rdf:resource="http://nomisma.org/"/>
		</lawd:Place>
	</xsl:template>
</xsl:stylesheet>
