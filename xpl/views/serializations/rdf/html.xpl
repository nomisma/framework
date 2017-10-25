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
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#data"/>		
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				
				<xsl:variable name="hasMints" as="item()*">
					<classes>
						<class>nmo:Collection</class>
						<class>nmo:Denomination</class>
						<!--<class>rdac:Family</class>
						<class>nmo:Ethnic</class>
						<class>foaf:Group</class>-->
						<class>nmo:Hoard</class>
						<class>nmo:Manufacture</class>
						<class>nmo:Material</class>
						<class>nmo:Mint</class>
						<class>nmo:ObjectType</class>
						<!--<class>foaf:Organization</class>-->
						<class>foaf:Person</class>
						<class>nmo:Region</class>
						<class>nmo:TypeSeries</class>
					</classes>
				</xsl:variable>
				
				<xsl:variable name="hasFindspots" as="item()*">
					<classes>
						<class>nmo:Denomination</class>
						<!--<class>rdac:Family</class>
						<class>nmo:Ethnic</class>
						<class>foaf:Group</class>-->
						<class>nmo:Manufacture</class>
						<class>nmo:Material</class>
						<class>nmo:Mint</class>
						<class>nmo:ObjectType</class>								
						<!--<class>foaf:Organization</class>-->
						<class>foaf:Person</class>
						<class>nmo:Region</class>
					</classes>
				</xsl:variable>
				
				<xsl:variable name="hasTypes" as="item()*">
					<classes>						
						<class>nmo:Denomination</class>
						<class>rdac:Family</class>
						<class>nmo:Ethnic</class>
						<class>foaf:Group</class>
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
						<xsl:attribute name="hasMints">
							<xsl:choose>
								<xsl:when test="$hasMints//class[text()=$type]">true</xsl:when>
								<xsl:otherwise>false</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="hasFindspots">
							<xsl:choose>
								<xsl:when test="$hasFindspots//class[text()=$type]">true</xsl:when>
								<xsl:otherwise>false</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="hasTypes">
							<xsl:choose>
								<xsl:when test="$hasTypes//class[text()=$type]">true</xsl:when>
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

	<!-- ASK whether there are geographic coordinates for mints or findspots in order to generate a conditional for the map -->
	<p:choose href="#type">
		<!-- suppress any class of object for which we do not want to render a map -->
		<p:when test="type/@hasMints = 'false'">
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
				<p:input name="data" href="#type"/>
				<p:input name="config-xml" href=" ../../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
						<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
						<xsl:variable name="type" select="/type"/>

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
								<xsl:when test="$type='nmo:Mint'"><![CDATA[ASK {nm:ID geo:location ?loc}]]></xsl:when>
								<xsl:when test="$type='nmo:Region'"><![CDATA[ASK {
  {nm:ID geo:location ?loc}
  UNION {?mint skos:broader+ nm:ID ;
          geo:location ?loc}}]]></xsl:when>
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
          ?obj nmo:hasMint ?place }
UNION {?obj PROP nm:ID .
	?obj nmo:hasObverse ?obv .
          ?obj nmo:hasMint ?place }
UNION {?rev PROP nm:ID .
	?obj nmo:hasReverse ?rev .
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
				<p:output name="data" id="mint-url-data"/>
			</p:processor>
			
			<p:processor name="oxf:exception-catcher">
				<p:input name="data" href="#mint-url-data"/>
				<p:output name="data" id="mint-url-data-checked"/>
			</p:processor>
			
			<!-- Check whether we had an exception -->
			<p:choose href="#mint-url-data-checked">
				<p:when test="/exceptions">
					<!-- Extract the message -->
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
				<p:otherwise>
					<!-- Just return the document -->
					<p:processor name="oxf:identity">
						<p:input name="data" href="#mint-url-data-checked"/>
						<p:output name="data" id="hasMints"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:otherwise>
	</p:choose>

	<p:choose href="#type">
		<!-- suppress any class of object for which we do not want to render a map -->
		<p:when test="type/@hasFindspots = 'false'">
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
				<p:input name="data" href="#type"/>
				<p:input name="config-xml" href=" ../../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
						<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
						<xsl:variable name="type" select="/type"/>

						<xsl:variable name="classes" as="item()*">
							<classes>
								<class prop="nmo:hasDenomination">nmo:Denomination</class>
								<class prop="?prop">rdac:Family</class>
								<class prop="?prop">nmo:Ethnic</class>
								<class prop="?prop">foaf:Group</class>
								<class prop="nmo:hasManufacture">nmo:Manufacture</class>
								<class prop="nmo:hasMaterial">nmo:Material</class>
								<class prop="nmo:hasMint">nmo:Mint</class>
								<class prop="nmo:representsObjectType">nmo:ObjectType</class>								
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
	<xsl:when test="$type='foaf:Person'"><![CDATA[ASK {
{{ ?s PROP nm:ID }
UNION {?s nmo:hasObverse ?obv .
       ?obv nmo:hasPortrait nm:ID }
UNION {?s nmo:hasReverse ?rev .
       ?rev nmo:hasPortrait nm:ID }
  }
  
{?object nmo:hasTypeSeriesItem ?s ;
	a nmo:NumismaticObject ;
  nmo:hasFindspot ?place }
UNION { ?object a nmo:NumismaticObject ;
	nmo:hasFindspot ?place }
UNION { ?object dcterms:isPartOf ?hoard .
  ?hoard a nmo:Hoard ;
           nmo:hasFindspot ?place }
UNION {?contents nmo:hasTypeSeriesItem ?s ;
                  a dcmitype:Collection .
  ?object dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?place }
UNION { ?contents PROP nm:ID ;
                  a dcmitype:Collection .
  ?object dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?place }
}]]></xsl:when>
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
				<p:output name="data" id="findspot-url-data"/>
			</p:processor>
			
			<p:processor name="oxf:exception-catcher">
				<p:input name="data" href="#findspot-url-data"/>
				<p:output name="data" id="findspot-url-data-checked"/>
			</p:processor>
			
			<!-- Check whether we had an exception -->
			<p:choose href="#findspot-url-data-checked">
				<p:when test="/exceptions">
					<!-- Extract the message -->
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
				<p:otherwise>
					<!-- Just return the document -->
					<p:processor name="oxf:identity">
						<p:input name="data" href="#findspot-url-data-checked"/>
						<p:output name="data" id="hasFindspots"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:otherwise>
	</p:choose>
	
	<!-- ASK whether there are coin types associated with the concept -->
	<p:choose href="#type">
		<!-- suppress any class of object for which we do not want to render a map -->
		<p:when test="type/@hasTypes = 'false'">
			<p:processor name="oxf:identity">
				<p:input name="data">
					<sparql xmlns="http://www.w3.org/2005/sparql-results#">
						<head/> 
						<boolean>false</boolean>
					</sparql>
				</p:input>
				<p:output name="data" id="hasTypes"/>
			</p:processor>
		</p:when>
		<!-- execute SPARQL query for other classes of object -->
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#type"/>
				<p:input name="config-xml" href=" ../../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
						<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
						<xsl:variable name="type" select="/type"/>
						
						<xsl:variable name="classes" as="item()*">
							<classes>
								<class prop="nmo:hasDenomination">nmo:Denomination</class>
								<class prop="?prop">rdac:Family</class>
								<class prop="?prop">nmo:Ethnic</class>
								<class prop="?prop">foaf:Group</class>
								<class prop="nmo:hasManufacture">nmo:Manufacture</class>
								<class prop="nmo:hasMaterial">nmo:Material</class>
								<class prop="nmo:hasMint">nmo:Mint</class>
								<class prop="nmo:representsObjectType">nmo:ObjectType</class>								
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
ASK {?s PROP nm:ID ; a nmo:TypeSeriesItem }]]></xsl:variable>
						
						
						
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
				<p:output name="data" id="hasTypes-url-generator-config"/>
			</p:processor>
			
			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#hasTypes-url-generator-config"/>
				<p:output name="data" id="type-url-data"/>
			</p:processor>
			
			<p:processor name="oxf:exception-catcher">
				<p:input name="data" href="#type-url-data"/>
				<p:output name="data" id="type-url-data-checked"/>
			</p:processor>
			
			<!-- Check whether we had an exception -->
			<p:choose href="#type-url-data-checked">
				<p:when test="/exceptions">
					<!-- Extract the message -->
					<p:processor name="oxf:identity">
						<p:input name="data">
							<sparql xmlns="http://www.w3.org/2005/sparql-results#">
								<head/>
								<boolean>false</boolean>
							</sparql>
						</p:input>
						<p:output name="data" id="hasTypes"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<!-- Just return the document -->
					<p:processor name="oxf:identity">
						<p:input name="data" href="#type-url-data-checked"/>
						<p:output name="data" id="hasTypes"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:otherwise>
	</p:choose>

	<!-- aggregate models and serialize into HTML -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #data, ../../../../config.xml, #hasMints, #hasFindspots, #hasTypes)"/>
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
