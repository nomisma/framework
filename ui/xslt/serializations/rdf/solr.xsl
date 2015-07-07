<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:nomisma="http://nomisma.org/" xmlns:org="http://www.w3.org/ns/org#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="solr-templates.xsl"/>
	
	<xsl:variable name="id_path" select="/content/config/id_path"/>
	
	<!-- definition of namespaces for turning in solr type field URIs into abbreviations -->
	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="//rdf:RDF/namespace::*[not(name()='xml')]">
				<namespace prefix="{name()}" uri="{.}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>
	
	<xsl:variable name="roles" as="element()*">
		<roles>
			<xsl:for-each select="distinct-values(descendant::org:role[contains(@rdf:resource, 'nomisma.org')]/@rdf:resource)">
				<role uri="{.}">
					<xsl:value-of select="document(concat('file://', $id_path, '/', substring-after(., 'id/'), '.rdf'))//skos:prefLabel[@xml:lang='en']"/>
				</role>
			</xsl:for-each>
		</roles>		
	</xsl:variable>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="/content/rdf:RDF/*[rdf:type/@rdf:resource='http://www.w3.org/2004/02/skos/core#Concept'][not(child::dcterms:isReplacedBy)]" mode="generateDoc"/>
		</add>
	</xsl:template>
</xsl:stylesheet>
