<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:oac="http://www.openannotation.org/ns/" exclude-result-prefixes="xs" version="2.0">

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="//doc"/>
		</rdf:RDF>
	</xsl:template>
	
	<xsl:template match="doc">
		<oac:Annotation rdf:about="http://nomisma.org/pelagios.rdf#{str[@name='id']}">
			<dcterms:title>
				<xsl:value-of select="str[@name='prefLabel']"/>
			</dcterms:title>
			<xsl:for-each select="distinct-values(arr[@name='pleiades_uri']/str)">
				<oac:hasBody rdf:resource="{.}#this"/>
			</xsl:for-each>
			<oac:hasTarget rdf:resource="http://nomisma.org/id/{str[@name='id']}"/>
		</oac:Annotation>
	</xsl:template>
</xsl:stylesheet>
