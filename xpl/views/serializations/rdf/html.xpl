<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
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

	<!-- ASK whether there are geographic coordinates for mints or findspots in order to generate a conditional for the map -->
	<p:choose href="#data">
		<!-- suppress any class of object for which we do not want to render a map -->
		<p:when test="/rdf:RDF/*[1]/name() = 'nmo:ReferenceWork' or /rdf:RDF/*[1]/name() = 'nmo:TypeSeries' or /rdf:RDF/*[1]/name() = 'nmo:FieldOfNumismatics' or /rdf:RDF/*[1]/name() =
			'nmo:NumismaticTerm' or  /rdf:RDF/*[1]/name() = 'org:Role' or  /rdf:RDF/*[1]/name() = 'nmo:Uncertainty' or  /rdf:RDF/*[1]/name() = 'nmo:CoinWear'">
			<p:processor name="oxf:identity">
				<p:input name="data">
					<sparql xmlns="http://www.w3.org/2005/sparql-results#">
						<head/>
						<boolean>false</boolean>
					</sparql>
				</p:input>
				<p:output name="data" id="hasMints"/>
			</p:processor>
		</p:when>
		<!-- apply alternate SPARQL query to get mints associated with a Hoard -->
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#data"/>
				<p:input name="config-xml" href=" ../../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
						<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
						<xsl:variable name="type" select="/rdf:RDF/*[1]/name()"/>

						<xsl:variable name="classes" as="item()*">
							<classes>
								<class prop="nmo:hasCollection">nmo:Collection</class>
								<class prop="nmo:hasDenomination">nmo:Denomination</class>
								<class prop="?prop">rdac:Family</class>
								<class prop="?prop">nmo:Ethnic</class>
								<class prop="?prop">foaf:Group</class>
								<class prop="dcterms:isPartOf">nmo:Hoard</class>
								<class prop="nmo:hasManufacture">nmo:Manufacture</class>
								<class prop="nmo:hasMaterial">nmo:Material</class>
								<class prop="nmo:hasMint">nmo:Mint</class>
								<class prop="nmo:representsObjectType">nmo:ObjectType</class>
								<class prop="?prop">foaf:Organization</class>
								<class prop="?prop">foaf:Person</class>
								<class prop="nmo:hasRegion">nmo:Region</class>
								<class prop="dcterms:source">nmo:TypeSeries</class>
							</classes>
						</xsl:variable>


						<xsl:variable name="query"><![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX dcmitype:	<http://purl.org/dc/dcmitype/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX osgeo:	<http://data.ordnancesurvey.co.uk/ontology/geometry/>
PREFIX org: <http://www.w3.org/ns/org#>]]>
							<xsl:choose>
								<xsl:when test="$type='nmo:Mint' or $type='nmo:Region'"><![CDATA[ASK {nm:ID geo:location ?loc}]]></xsl:when>
								<xsl:when test="$type='nmo:Hoard'"><![CDATA[ASK {?coin dcterms:isPartOf nm:ID ;
  	rdf:type nmo:NumismaticObject
  {?coin nmo:hasTypeSeriesItem ?type .
        ?type nmo:hasMint ?place}
  UNION {?coin nmo:hasMint ?place}
   ?place geo:location ?loc }]]>
								</xsl:when>
								<xsl:when test="$type='nmo:Collection'"><![CDATA[ASK {
  ?coin nmo:hasCollection nm:ID .
  {?coin nmo:hasTypeSeriesItem ?type .
        ?type nmo:hasMint ?place}
  UNION {?coin nmo:hasMint ?place}
  ?place geo:location ?loc}]]>
								</xsl:when>
								<xsl:when test="$type='foaf:Person'"><![CDATA[ASK {
{?obj PROP nm:ID .
	MINUS {?obj dcterms:isReplacedBy ?replaced}
          ?obj nmo:hasMint ?place }
UNION { nm:ID org:hasMembership ?membership .
 ?membership org:organization ?place .
 ?place rdf:type nmo:Mint }
 ?place geo:location ?loc }]]>
								</xsl:when>
								<xsl:otherwise><![CDATA[ASK {
{?obj PROP nm:ID .
	MINUS {?obj dcterms:isReplacedBy ?replaced}
          ?obj nmo:hasMint ?place}
UNION { ?obj PROP nm:ID .
	MINUS {?obj dcterms:isReplacedBy ?replaced}
          ?obj nmo:hasMint ?place }
  ?place geo:location ?loc }]]>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<xsl:template match="/">
							<xsl:variable name="service">
								<xsl:choose>
									<xsl:when test="$type='nmo:Hoard' or $type='nmo:Collection' or $type='nmo:Mint' or $type='nmo:Region'">
										<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'ID', $id))), '&amp;output=xml')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace(replace($query, 'ID', $id), 'PROP',
											$classes//class[text()=$type]/@prop))), '&amp;output=xml')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>


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
				<p:output name="data" id="hasMints-url-generator-config"/>
			</p:processor>

			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#hasMints-url-generator-config"/>
				<p:output name="data" id="hasMints"/>
			</p:processor>
		</p:otherwise>
	</p:choose>

	<p:choose href="#data">
		<!-- suppress any class of object for which we do not want to render a map -->
		<p:when test="/rdf:RDF/*[1]/name() = 'nmo:ReferenceWork' or /rdf:RDF/*[1]/name() = 'nmo:TypeSeries' or /rdf:RDF/*[1]/name() = 'nmo:FieldOfNumismatics' or /rdf:RDF/*[1]/name() =
			'nmo:NumismaticTerm' or  /rdf:RDF/*[1]/name() = 'org:Role' or  /rdf:RDF/*[1]/name() = 'nmo:Uncertainty' or /rdf:RDF/*[1]/name() = 'nmo:CoinWear' or /rdf:RDF/*[1]/name() = 'nmo:Collection'">
			<p:processor name="oxf:identity">
				<p:input name="data">
					<sparql xmlns="http://www.w3.org/2005/sparql-results#">
						<head/> 
						<boolean>false</boolean>
					</sparql>
				</p:input>
				<p:output name="data" id="hasFindspots"/>
			</p:processor>
		</p:when>
		<!-- execute SPARQL query for other classes of object -->
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#data"/>
				<p:input name="config-xml" href=" ../../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
						<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
						<xsl:variable name="type" select="/rdf:RDF/*[1]/name()"/>

						<xsl:variable name="classes" as="item()*">
							<classes>
								<class prop="nmo:hasDenomination">nmo:Denomination</class>
								<class prop="?prop">rdac:Family</class>
								<class prop="?prop">nmo:Ethnic</class>
								<class prop="?prop">foaf:Group</class>
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
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>]]>

<xsl:choose>
	<xsl:when test="$type='nmo:Hoard'"><![CDATA[ASK {nm:ID nmo:hasFindspot ?loc}]]></xsl:when>
	<xsl:otherwise>
		<![CDATA[ASK {
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
    nmo:hasFindspot ?place }}]]>
	</xsl:otherwise>
</xsl:choose>
</xsl:variable>



						<xsl:template match="/">
							<xsl:variable name="service">
								<xsl:choose>
									<xsl:when test="$type='nmo:Hoard'">
										<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'ID', $id))), '&amp;output=xml')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace(replace($query, 'ID', $id), 'PROP',
											$classes//class[text()=$type]/@prop))), '&amp;output=xml')"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>							

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
				<p:output name="data" id="hasFindspots-url-generator-config"/>
			</p:processor>

			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#hasFindspots-url-generator-config"/>
				<p:output name="data" id="hasFindspots"/>
			</p:processor>
		</p:otherwise>
	</p:choose>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #data, ../../../../config.xml, #hasMints, #hasFindspots)"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/rdf/html.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:html-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<version>5.0</version>
				<indent>true</indent>
				<content-type>text/html</content-type>
				<encoding>utf-8</encoding>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
