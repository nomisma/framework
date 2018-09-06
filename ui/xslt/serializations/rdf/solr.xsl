<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:nmo="http://nomisma.org/ontology#" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:nomisma="http://nomisma.org/" xmlns:org="http://www.w3.org/ns/org#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="solr-templates.xsl"/>

	<xsl:variable name="id_path" select="/content/config/id_path"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_query"/>

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

	<xsl:variable name="fields" as="element()*">
		<fields>
			<!-- only execute SPARQL query to gather fields of numismatics if there is a decendent field in the RDF model -->
			<xsl:if test="descendant::dcterms:isPartOf[matches(@rdf:resource, 'nomisma\.org/id/.*_numismatics')]">
				<xsl:for-each select="distinct-values(descendant::dcterms:isPartOf[matches(@rdf:resource, 'nomisma\.org/id/.*_numismatics')]/@rdf:resource)">
					<xsl:variable name="uri" select="."/>

					<xsl:variable name="query">
						<![CDATA[ PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
SELECT ?label ?broader ?broaderLabel WHERE {
<URI> skos:prefLabel ?label FILTER langMatches(lang(?label), "en")
OPTIONAL {<URI> skos:broader ?broader .
         ?broader  skos:prefLabel ?broaderLabel FILTER langMatches(lang(?broaderLabel), "en")}}]]>
					</xsl:variable>

					<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'URI', $uri)), '&amp;output=xml')"/>

					<xsl:variable name="response" as="element()*">
						<response xmlns:res="http://www.w3.org/2005/sparql-results#">
							<xsl:copy-of select="document($service)//res:result"/>
						</response>
					</xsl:variable>

					<field uri="{$uri}">
						<name>
							<xsl:value-of select="$response//res:result[1]/res:binding[@name='label']/res:literal"/>
						</name>
						<xsl:for-each select="$response//res:result/res:binding[@name='broader']">
							<broader uri="{res:uri}">
								<xsl:value-of select="parent::res:result/res:binding[@name='broaderLabel']/res:literal"/>
							</broader>
						</xsl:for-each>
					</field>
				</xsl:for-each>
			</xsl:if>
		</fields>
	</xsl:variable>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="/rdf:RDF/*[rdf:type/@rdf:resource = 'http://www.w3.org/2004/02/skos/core#Concept' and skos:inScheme/@rdf:resource = 'http://nomisma.org/id/'][not(child::dcterms:isReplacedBy)]"
				mode="generateDoc"/>
		</add>
	</xsl:template>
</xsl:stylesheet>
