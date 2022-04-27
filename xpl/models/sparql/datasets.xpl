<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date modified: April 2022
	Function: Submit a SPARQL query to generate a list of external datasets aggregated into Nomisma.org
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

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
				
				<xsl:variable name="query"><![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX void:	<http://rdfs.org/ns/void#>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX dcmitype: <http://purl.org/dc/dcmitype/>
CONSTRUCT {?uri rdf:type void:Dataset ; 
  dcterms:publisher ?publisher; 
  dcterms:title ?title ; 
  dcterms:description ?description ;
  dcterms:license ?license ;
  dcterms:rights ?rights ;
  dcterms:type ?type ;  
  void:dataDump ?dump ;
  dcterms:hasPart [a dcmitype:Collection ;
                   dcterms:type ?type;
                   void:entities ?count]}
WHERE {   
  ?uri a void:Dataset ; 
  	void:dataDump ?dump ; 
  	dcterms:description ?description FILTER (lang(?description) = "" || langMatches(lang(?description), "en")) .
  	OPTIONAL {?uri dcterms:rights ?rights }
    OPTIONAL {?uri dcterms:license ?license }
  	?uri dcterms:publisher | dcterms:publisher/skos:prefLabel ?publisher FILTER (isLiteral(?publisher)) .
  ?uri dcterms:title ?title FILTER (lang(?title) = "" || langMatches(lang(?title), "en")).
  { SELECT ?uri ?type  (count(?object) as ?count ) WHERE {
      ?object void:inDataset ?uri ;
             rdf:type ?type FILTER (?type != skos:Concept)
    } GROUP BY ?uri ?type
  }
} ORDER BY ASC(?publisher) ASC(?title)]]>
				</xsl:variable>

				<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri($query), '&amp;output=xml')"/>
				
				<xsl:template match="/">
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
		<p:output name="data" id="url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
