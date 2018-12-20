<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<!-- first validate -->
	<p:choose href="#request">
		<p:when test="not(string(/request/parameters/parameter[name='baseUri']/value))">
			<p:processor name="oxf:identity">
				<p:input name="data">
					<error>baseUri parameter is required.</error>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
			
		</p:when>
		<p:when test="not(string(/request/parameters/parameter[name='identifiers']/value))">
			<p:processor name="oxf:identity">
				<p:input name="data">
					<error>identifiers are required.</error>					
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<!-- generate identifier list -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#request"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<xsl:param name="identifiers" select="/request/parameters/parameter[name='identifiers']/value"/>
						<xsl:param name="baseUri" select="/request/parameters/parameter[name='baseUri']/value"/>
						
						<xsl:template match="/">
							<identifiers>
								<xsl:for-each select="tokenize($identifiers, '\|')">
									<identifier>
										<xsl:value-of select="normalize-space(.)"/>
									</identifier>
								</xsl:for-each>
							</identifiers>
						</xsl:template>
						
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="identifiers"/>
			</p:processor>
			
			<!-- iterate through identifiers -->
			<p:for-each href="#identifiers" select="//identifier" root="response" id="response">
				<p:processor name="oxf:identity">
					<p:input name="data" href="current()"/>
					<p:output name="data" id="id"/>
				</p:processor>
				
				<!-- execute SPARQL for hoard/object counts -->
				<p:processor name="oxf:unsafe-xslt">
					<p:input name="request" href="#request"/>
					<p:input name="config-xml" href=" ../../../config.xml"/>
					<p:input name="data" href="current()"/>
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">							
							<xsl:param name="baseUri" select="doc('input:request')/request/parameters/parameter[name='baseUri']/value"/>
							<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
							<xsl:variable name="query">
								<![CDATA[PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcmitype:	<http://purl.org/dc/dcmitype/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nm: <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT ?type (count(?type) as ?count) WHERE {
{ ?object a nmo:NumismaticObject ;
 nmo:hasTypeSeriesItem <typeUri>}
UNION { <typeUri> skos:exactMatch ?match .
?object nmo:hasTypeSeriesItem ?match ;
  a nmo:NumismaticObject }
UNION { ?broader skos:broader+ <typeUri> .
?object nmo:hasTypeSeriesItem ?broader ;
  a nmo:NumismaticObject }
UNION { ?contents a dcmitype:Collection ; 
  nmo:hasTypeSeriesItem <typeUri> .
?object dcterms:tableOfContents ?contents }
?object rdf:type ?type .
} GROUP BY ?type]]></xsl:variable>
							
							
							
							<xsl:template match="/">
								<xsl:variable name="uri" select="concat($baseUri, .)"/>
								<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
								
								<config>
									<url>
										<xsl:value-of select="$service"/>
									</url>
									<content-type>application/xml</content-type>
									<encoding>utf-8</encoding>
								</config>								
							</xsl:template>
							
						</xsl:stylesheet>
					</p:input>
					<p:output name="data" id="count-url-generator-config"/>
				</p:processor>
				
				<!-- query SPARQL -->
				<p:processor name="oxf:url-generator">
					<p:input name="config" href="#count-url-generator-config"/>
					<p:output name="data" id="counts"/>
				</p:processor>
				
				<!-- execute SPARQL query for images -->
				<p:processor name="oxf:unsafe-xslt">
					<p:input name="request" href="#request"/>
					<p:input name="config-xml" href=" ../../../config.xml"/>
					<p:input name="data" href="current()"/>
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">							
							<xsl:param name="baseUri" select="doc('input:request')/request/parameters/parameter[name='baseUri']/value"/>
							<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
							<xsl:variable name="query">
								<![CDATA[PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nm: <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX void:	<http://rdfs.org/ns/void#>
SELECT ?object ?identifier ?collection ?datasetTitle ?obvThumb ?revThumb ?obvRef ?revRef ?comThumb ?comRef WHERE {
{ ?object a nmo:NumismaticObject ;
 nmo:hasTypeSeriesItem <typeUri>}
UNION { ?broader skos:broader+ <typeUri> .
?object nmo:hasTypeSeriesItem ?broader ;
  a nmo:NumismaticObject }
OPTIONAL { ?object dcterms:identifier ?identifier }
OPTIONAL { ?object nmo:hasCollection ?colUri .
?colUri skos:prefLabel ?collection FILTER(langMatches(lang(?collection), "EN"))}
?object void:inDataset ?dataset .
?dataset dcterms:title ?datasetTitle FILTER (lang(?datasetTitle) = "" || langMatches(lang(?datasetTitle), "en")) .
OPTIONAL { ?object foaf:thumbnail ?comThumb }
OPTIONAL { ?object foaf:depiction ?comRef }
OPTIONAL { ?object nmo:hasObverse ?obverse .
?obverse foaf:thumbnail ?obvThumb }
OPTIONAL { ?object nmo:hasObverse ?obverse .
?obverse foaf:depiction ?obvRef }
OPTIONAL { ?object nmo:hasReverse ?reverse .
?reverse foaf:thumbnail ?revThumb }
OPTIONAL { ?object nmo:hasReverse ?reverse .
?reverse foaf:depiction ?revRef }
} ORDER BY ASC(?datasetTitle) LIMIT 5]]></xsl:variable>
							
							
							
							<xsl:template match="/">
								<xsl:variable name="uri" select="concat($baseUri, .)"/>
								<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
								
								<config>
									<url>
										<xsl:value-of select="$service"/>
									</url>
									<content-type>application/xml</content-type>
									<encoding>utf-8</encoding>
								</config>								
							</xsl:template>
							
						</xsl:stylesheet>
					</p:input>
					<p:output name="data" id="images-url-generator-config"/>
				</p:processor>
				
				<p:processor name="oxf:url-generator">
					<p:input name="config" href="#images-url-generator-config"/>
					<p:output name="data" id="images"/>
				</p:processor>
				
				<p:processor name="oxf:identity">
					<p:input name="data" href="aggregate('content', #id, #counts, #images)"/>
					<p:output name="data" ref="response"/>
				</p:processor>				
			</p:for-each>
			
			<p:processor name="oxf:identity">
				<p:input name="data" href="#response"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
	
</p:config>
