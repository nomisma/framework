<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki.
	Function: get an HTML (text) response for related coin types to display via AJAX in a record page
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

	<!--<p:processor name="oxf:pipeline">
		<p:input name="config" href="../rdf/get-id.xpl"/>
		<p:output name="data" id="rdf"/>
	</p:processor>-->
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>		
		<p:input name="data" href=" ../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
				<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
				
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>		
				
				<xsl:variable name="classes" as="item()*">
					<classes>
						<class map="false" types="false">nmo:Collection</class>
						<class map="true" types="true" prop="nmo:hasDenomination">nmo:Denomination</class>
						<class map="true" types="true" prop="?prop">rdac:Family</class>
						<class map="true" types="false">nmo:Ethnic</class>
						<class map="false" types="false">nmo:FieldOfNumismatics</class>
						<class map="true" types="false">nmo:Hoard</class>
						<class map="true" types="true" prop="nmo:hasManufacture">nmo:Manufacture</class>
						<class map="true" types="true" prop="nmo:hasMaterial">nmo:Material</class>
						<class map="true" types="true" prop="nmo:hasMint">nmo:Mint</class>
						<class map="false" types="false">nmo:NumismaticTerm</class>
						<class map="true" types="false">nmo:ObjectType</class>
						<class map="true" types="true" prop="?prop">foaf:Group</class>
						<class map="true" types="true" prop="?prop">foaf:Organization</class>			
						<class map="true" types="true" prop="?prop">foaf:Person</class>
						<class map="false" types="false">crm:E4_Period</class>
						<class>nmo:ReferenceWork</class>
						<class map="true" types="true" prop="nmo:hasRegion">nmo:Region</class>
						<class map="false" types="false">org:Role</class>
						<class map="false" types="false">nmo:TypeSeries</class>
						<class map="false" types="false">un:Uncertainty</class>
						<class map="false" types="false">nmo:CoinWear</class>
					</classes>
				</xsl:variable>
				
				
				<xsl:variable name="query">
					<xsl:choose>
						<xsl:when test="$type='foaf:Person'">
							<![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT * WHERE {
 { ?type PROP nm:ID }
 UNION { ?type nmo:hasObverse ?obv . ?obv PROP nm:ID }
 UNION { ?type nmo:hasReverse ?rev . ?rev PROP nm:ID }
   ?type a nmo:TypeSeriesItem ;
   skos:prefLabel ?label FILTER(langMatches(lang(?label), "en")) .
   MINUS {?type dcterms:isReplacedBy ?replaced}
   ?type dcterms:source ?source . 
   	?source skos:prefLabel ?sourceLabel FILTER(langMatches(lang(?sourceLabel), "en"))
   OPTIONAL {?type nmo:hasStartDate ?startDate}
   OPTIONAL {?type nmo:hasEndDate ?endDate}
   OPTIONAL {?type nmo:hasMint ?mint . 
   	?mint skos:prefLabel ?mintLabel FILTER(langMatches(lang(?mintLabel), "en"))}
   OPTIONAL {?type nmo:hasDenomination ?den . 
   	?den skos:prefLabel ?denLabel FILTER(langMatches(lang(?denLabel), "en"))}
}]]>
						</xsl:when>
						<xsl:otherwise>
							<![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT * WHERE {
 ?type PROP nm:ID ;
   a nmo:TypeSeriesItem ;
   skos:prefLabel ?label FILTER(langMatches(lang(?label), "en")) .
   MINUS {?type dcterms:isReplacedBy ?replaced}
   ?type dcterms:source ?source . 
   	?source skos:prefLabel ?sourceLabel FILTER(langMatches(lang(?sourceLabel), "en"))
   OPTIONAL {?type nmo:hasStartDate ?startDate}
   OPTIONAL {?type nmo:hasEndDate ?endDate}
   OPTIONAL {?type nmo:hasMint ?mint . 
   	?mint skos:prefLabel ?mintLabel FILTER(langMatches(lang(?mintLabel), "en"))}
   OPTIONAL {?type nmo:hasDenomination ?den . 
   	?den skos:prefLabel ?denLabel FILTER(langMatches(lang(?denLabel), "en"))}
}]]>
						</xsl:otherwise>
					</xsl:choose>
					</xsl:variable>
				
				<xsl:template match="/">
					<xsl:variable name="prop" select="$classes//class[text()=$type]/@prop"/>
					
					<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(concat(replace(replace($query, 'ID', $id), 'PROP', $prop), ' LIMIT 10')), '&amp;output=xml')"/>
					
					
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
</p:config>
