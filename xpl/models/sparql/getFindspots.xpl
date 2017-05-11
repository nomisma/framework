<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

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

	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../rdf/get-id.xpl"/>
		<p:output name="data" id="rdf"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#rdf"/>		
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				
				<xsl:variable name="hasFindspots" as="item()*">
					<classes>
						<class>nmo:Denomination</class>
						<class>rdac:Family</class>
						<class>nmo:Ethnic</class>
						<class>foaf:Group</class>
						<class>nmo:Manufacture</class>
						<class>nmo:Material</class>
						<class>nmo:Mint</class>
						<class>nmo:ObjectType</class>								
						<class>foaf:Organization</class>
						<class>foaf:Person</class>
						<class>nmo:Region</class>
					</classes>
				</xsl:variable>
				
				<xsl:variable name="type" select="/rdf:RDF/*[1]/name()"/>
				
				
				<xsl:template match="/">
					<type>
						<xsl:attribute name="hasFindspots">
							<xsl:choose>
								<xsl:when test="$hasFindspots//class[text()=$type]">true</xsl:when>
								<xsl:otherwise>false</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>						
						
						<xsl:value-of select="$type"/>
					</type>
				</xsl:template>
				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="type"/>
	</p:processor>
	
	<p:choose href="#type">
		<!-- if the ID is itself a hoard, then render from RDF -->
		<p:when test="type = 'nmo:Hoard'">
			<p:processor name="oxf:identity">
				<p:input name="data" href="#rdf"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<!-- suppress any class of object for which we do not want to render a map -->
		<p:when test="type/@hasFindspots = 'false'">
			<p:processor name="oxf:identity">
				<p:input name="data">
					<null/>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<!-- execute SPARQL query for other classes of object -->
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#type"/>
				<p:input name="config-xml" href=" ../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
						<xsl:param name="api" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
						<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
						<xsl:variable name="type" select="/type"/>
						
						<xsl:variable name="classes" as="item()*">
							<classes>						
								<class prop="nmo:hasDenomination">nmo:Denomination</class>
								<class prop="?prop">rdac:Family</class>
								<class prop="?prop">nmo:Ethnic</class>						
								<class prop="nmo:hasManufacture">nmo:Manufacture</class>
								<class prop="nmo:hasMaterial">nmo:Material</class>
								<class prop="nmo:hasMint">nmo:Mint</class>
								<class prop="?prop">foaf:Organization</class>
								<class prop="?prop">foaf:Person</class>
								<class prop="nmo:hasRegion">nmo:Region</class>
							</classes>
						</xsl:variable>
						
						<!-- construct different queries for individual finds, hoards, and combined for heatmap -->
						<xsl:variable name="query"><![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX dcmitype:	<http://purl.org/dc/dcmitype/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>
]]>
<xsl:choose>
	<xsl:when test="$api = 'heatmap'">
		<xsl:choose>
			<xsl:when test="$type='foaf:Person'">
				<![CDATA[SELECT DISTINCT ?place ?label ?lat ?long WHERE {
{ ?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem . 
 ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  nmo:hasFindspot ?place }
UNION {?obv nmo:hasPortrait nm:ID .
?coinType nmo:hasObverse ?obv ;
  a nmo:TypeSeriesItem .
?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  nmo:hasFindspot ?place }
UNION {?rev nmo:hasPortrait nm:ID .
?coinType nmo:hasReverse ?rev ;
  a nmo:TypeSeriesItem .
?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  nmo:hasFindspot ?place }
  UNION { ?object PROP nm:ID ;
  	rdf:type nmo:NumismaticObject ;
  	nmo:hasFindspot ?place}
  UNION{ ?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem .
  ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  dcterms:isPartOf ?hoard .
  ?hoard nmo:hasFindspot ?place }
UNION { ?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem .
?contents nmo:hasTypeSeriesItem ?coinType ;
                  a dcmitype:Collection .
  ?object dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?place }
 UNION { ?contents PROP nm:ID ;
                  a dcmitype:Collection .
  ?object dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?place }
?place geo:lat ?lat ; geo:long ?long .
  OPTIONAL {?place foaf:name ?label}
  OPTIONAL {?place rdfs:label ?label}
  OPTIONAL {?nomismaURI geo:location ?place .
    ?nomismaURI skos:prefLabel ?label FILTER langMatches(lang(?label), "en")}
}]]>
			</xsl:when>
			<xsl:otherwise><![CDATA[SELECT DISTINCT ?place ?label ?lat ?long WHERE {
{ ?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem . 
 ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  nmo:hasFindspot ?place }
  UNION { ?object PROP nm:ID ;
  	rdf:type nmo:NumismaticObject ;
  	nmo:hasFindspot ?place}
  UNION{ ?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem .
  ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  dcterms:isPartOf ?hoard .
  ?hoard nmo:hasFindspot ?place }
UNION { ?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem .
?contents nmo:hasTypeSeriesItem ?coinType ;
                  a dcmitype:Collection .
  ?object dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?place }
 UNION { ?contents PROP nm:ID ;
                  a dcmitype:Collection .
  ?object dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?place }
?place geo:lat ?lat ; geo:long ?long .
  OPTIONAL {?place foaf:name ?label}
  OPTIONAL {?place rdfs:label ?label}
  OPTIONAL {?nomismaURI geo:location ?place .
    ?nomismaURI skos:prefLabel ?label FILTER langMatches(lang(?label), "en")}
}]]>	
			</xsl:otherwise>
		</xsl:choose>
		
		
	</xsl:when>
	<xsl:when test="$api = 'getFindspots'">
		<xsl:choose>
			<xsl:when test="$type='foaf:Person'">
				<![CDATA[SELECT DISTINCT ?place ?label ?lat ?long WHERE {
{ ?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem . 
 ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  nmo:hasFindspot ?place }
UNION {?obv nmo:hasPortrait nm:ID .
?coinType nmo:hasObverse ?obv ;
  a nmo:TypeSeriesItem .
?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  nmo:hasFindspot ?place }
UNION {?rev nmo:hasPortrait nm:ID .
?coinType nmo:hasReverse ?rev ;
  a nmo:TypeSeriesItem .
?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  nmo:hasFindspot ?place }
  UNION { ?object PROP nm:ID ;
  	rdf:type nmo:NumismaticObject ;
  	nmo:hasFindspot ?place}
  ?place geo:lat ?lat ; geo:long ?long .
  OPTIONAL {?place foaf:name ?label}
  OPTIONAL {?place rdfs:label ?label}
  OPTIONAL {?nomismaURI geo:location ?place .
    ?nomismaURI skos:prefLabel ?label FILTER langMatches(lang(?label), "en")}
  }]]>
			</xsl:when>
			<xsl:otherwise>
				<![CDATA[SELECT DISTINCT ?place ?label ?lat ?long WHERE {
{ ?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem . 
 ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  nmo:hasFindspot ?place }
  UNION { ?object PROP nm:ID ;
  	rdf:type nmo:NumismaticObject ;
  	nmo:hasFindspot ?place}
  ?place geo:lat ?lat ; geo:long ?long .
  OPTIONAL {?place foaf:name ?label}
  OPTIONAL {?place rdfs:label ?label}
  OPTIONAL {?nomismaURI geo:location ?place .
    ?nomismaURI skos:prefLabel ?label FILTER langMatches(lang(?label), "en")}
  }]]>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:when>
	<xsl:when test="$api = 'getHoards'">
		<xsl:choose>
			<xsl:when test="$type='foaf:Person'">
				<![CDATA[SELECT DISTINCT ?hoard ?hoardLabel ?closingDate ?place ?label ?lat ?long WHERE {
{?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem .
  ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  dcterms:isPartOf ?hoard .
  ?hoard nmo:hasFindspot ?place }
UNION {?obv nmo:hasPortrait nm:ID .
?coinType nmo:hasObverse ?obv ;
  a nmo:TypeSeriesItem .
  ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  dcterms:isPartOf ?hoard .
  ?hoard nmo:hasFindspot ?place }
UNION {?rev nmo:hasPortrait nm:ID .
?coinType nmo:hasReverse ?rev ;
  a nmo:TypeSeriesItem .
  ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  dcterms:isPartOf ?hoard .
  ?hoard nmo:hasFindspot ?place }
UNION { ?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem .
?contents nmo:hasTypeSeriesItem ?coinType ;
                  a dcmitype:Collection .
  ?hoard dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?place }
 UNION { ?contents PROP nm:ID ;
                  a dcmitype:Collection .
  ?hoard dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?place }
OPTIONAL {?hoard skos:prefLabel ?hoardLabel FILTER langMatches(lang(?hoardLabel), "en")}
OPTIONAL {?hoard dcterms:title ?hoardLabel FILTER langMatches(lang(?hoardLabel), "en")}
OPTIONAL {?hoard nmo:hasClosingDate ?closingDate}
?place geo:lat ?lat ; geo:long ?long .
    OPTIONAL {?place foaf:name ?label}}]]>
			</xsl:when>
			<xsl:otherwise>
				<![CDATA[SELECT DISTINCT ?hoard ?hoardLabel ?closingDate ?place ?label ?lat ?long WHERE {
{?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem .
  ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  dcterms:isPartOf ?hoard .
  ?hoard nmo:hasFindspot ?place }
UNION { ?coinType PROP nm:ID ;
  a nmo:TypeSeriesItem .
?contents nmo:hasTypeSeriesItem ?coinType ;
                  a dcmitype:Collection .
  ?hoard dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?place }
 UNION { ?contents PROP nm:ID ;
                  a dcmitype:Collection .
  ?hoard dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?place }
OPTIONAL {?hoard skos:prefLabel ?hoardLabel FILTER langMatches(lang(?hoardLabel), "en")}
OPTIONAL {?hoard dcterms:title ?hoardLabel FILTER langMatches(lang(?hoardLabel), "en")}
OPTIONAL {?hoard nmo:hasClosingDate ?closingDate}
?place geo:lat ?lat ; geo:long ?long .
    OPTIONAL {?place foaf:name ?label}}]]>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:when>
</xsl:choose>
							</xsl:variable>
						
						
						
						<xsl:template match="/">
							<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace(replace($query, 'ID', $id), 'PROP',
								$classes//class[text()=$type]/@prop))), '&amp;output=xml')"/>
							
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
			
			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#url-generator-config"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
