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

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:param name="page" select="tokenize(tokenize(doc('input:request')/request/request-url, '/')[last()], '\.')[2]"/>
				<xsl:variable name="limit">5000</xsl:variable>								
				<xsl:variable name="offset" select="if ($page castable as xs:integer) then xs:string(xs:integer($page) * $limit) else '0'"/>
				
				
				

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
				<xsl:variable name="query"><![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX void: <http://rdfs.org/ns/void#>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX svcs: <http://rdfs.org/sioc/services#>

SELECT ?coin ?title ?dataset ?startDate ?endDate ?comThumb ?comRef ?comManifest ?comService ?obvThumb ?obvRef ?obvManifest ?obvService ?revThumb ?revRef ?revManifest ?revService ?match WHERE {
?coin a nmo:NumismaticObject ;
        dcterms:title ?title ;
        void:inDataset ?dataset . FILTER (?dataset != <http://numismatics.org/search/> && ?dataset != <http://coins.lib.virginia.edu/> && ?dataset != <https://finds.org.uk/>) .
OPTIONAL { ?coin foaf:thumbnail ?comThumb }
OPTIONAL { ?coin foaf:depiction ?comRef 
	OPTIONAL { ?comRef dcterms:isReferencedBy ?comManifest ;
		svcs:has_service ?comService}}
OPTIONAL { ?coin nmo:hasObverse/foaf:thumbnail ?obvThumb }
OPTIONAL { ?coin nmo:hasObverse ?obverse .
?obverse foaf:depiction ?obvRef
	OPTIONAL { ?obvRef dcterms:isReferencedBy ?obvManifest;
		svcs:has_service ?obvService}}
OPTIONAL { ?coin nmo:hasReverse/foaf:thumbnail ?revThumb }
OPTIONAL { ?coin nmo:hasReverse ?reverse .
?reverse foaf:depiction ?revRef 
	OPTIONAL { ?revRef dcterms:isReferencedBy ?revManifest;
		svcs:has_service ?revService}}
?coin nmo:hasTypeSeriesItem ?type .
  OPTIONAL {?type nmo:hasStartDate ?startDate}
  OPTIONAL {?type nmo:hasEndDate ?endDate}
?type nmo:hasMint ?mint .
?mint skos:closeMatch ?match FILTER strStarts(str(?match), "http://pleiades")
} LIMIT %LIMIT% OFFSET %OFFSET%]]></xsl:variable>

				<xsl:variable name="service">
					<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%LIMIT%', $limit), '%OFFSET%', $offset)), '&amp;output=xml')"/>
				</xsl:variable>

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
