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
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="identifiers" select="/request/parameters/parameter[name='identifiers']/value"/>
				
				<xsl:template match="/">
					<identifiers>
						<xsl:for-each select="tokenize($identifiers, '\|')">
							<identifier><xsl:value-of select="."/></identifier>
						</xsl:for-each>
					</identifiers>
				</xsl:template>
				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="identifiers"/>
	</p:processor>
	
	<p:for-each href="#identifiers" select="//identifier" root="response" id="query-result">
		<!-- generator config for URL generator -->
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="identifier" href="current()"/>
			<p:input name="request" href="#request"/>
			<p:input name="data" href="../../../config.xml"/>
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
					<!-- request parameters -->
					<xsl:param name="id" select="doc('input:identifier')/identifier"/>
					<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
					
					<!-- config variables -->
					<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
					
					<xsl:variable name="query">
						<![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>						
SELECT ?uri ?type ?en ?lang ?lat ?long WHERE {
nm:%ID% skos:broader+ ?uri .
?uri rdf:type ?type FILTER (?type != <http://www.w3.org/2004/02/skos/core#Concept>).
?uri skos:prefLabel ?en . FILTER(langMatches(lang(?en), "en")).
OPTIONAL {?uri geo:location ?loc .
	?loc geo:lat ?lat ;
		geo:long ?long}
%lang%}]]>
					</xsl:variable>
					
					<xsl:variable name="lang-template">OPTIONAL {?uri skos:prefLabel ?lang . FILTER(langMatches(lang(?lang), "LANG"))}</xsl:variable>
					
					<xsl:variable name="service">
						<xsl:choose>
							<xsl:when test="string($lang)">
								<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace(replace($query, '%lang%', replace($lang-template, 'LANG', $lang)), '%ID%',
									$id))), '&amp;output=xml')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace(replace($query, '%lang%', ''), '%ID%', $id))), '&amp;output=xml')"/>
							</xsl:otherwise>
						</xsl:choose>
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
			<p:output name="data" ref="query-result"/>
		</p:processor>
	</p:for-each>
	
	<p:processor name="oxf:identity">
		<p:input name="data" href="#query-result"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
