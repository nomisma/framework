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
				<!-- request parameters -->
				<xsl:param name="api" select="substring-after(doc('input:request')/request/request-url, 'apis/')"/>
				<xsl:param name="constraints" select="doc('input:request')/request/parameters/parameter[name='constraints']/value"/>
				<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
				<xsl:variable name="measurement" select="lower-case(substring-after($api, 'avg'))"/>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
				
				<xsl:variable name="query"><![CDATA[ PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX xsd:	<http://www.w3.org/2001/XMLSchema#>
SELECT (AVG(xsd:decimal(?MEASUREMENT)) AS ?average)
WHERE {
<CONSTRAINTS>
}]]></xsl:variable>
				
				<xsl:variable name="replace">
					<xsl:choose>
						<xsl:when test="string($type)">
							<![CDATA[{ ?coin a nmo:NumismaticObject ;
 nmo:hasTypeSeriesItem <typeURI>}
UNION { <typeURI> skos:exactMatch ?match .
?coin nmo:hasTypeSeriesItem ?match ;
  a nmo:NumismaticObject }
UNION { ?broader skos:broader+ <typeURI> .
?coin nmo:hasTypeSeriesItem ?broader ;
  a nmo:NumismaticObject }
?coin nmo:hasMEASUREMENT ?MEASUREMENT]]>
						</xsl:when>
						<xsl:when test="string($constraints)">
							<xsl:text>{</xsl:text>
							<xsl:for-each select="tokenize($constraints, ' AND ')">
								<xsl:text>?coin </xsl:text>
								<xsl:value-of select="."/>
								<xsl:text> .</xsl:text>
							</xsl:for-each>
							<xsl:text>?coin nmo:hasMEASUREMENT ?MEASUREMENT</xsl:text>
							<xsl:text>} UNION {</xsl:text>
							<xsl:for-each select="tokenize($constraints, ' AND ')">
								<!-- ignore collection -->
								<xsl:if test="not(contains(., 'nmo:hasCollection'))">
									<xsl:text>?type </xsl:text>
									<xsl:value-of select="."/>
									<xsl:text> .</xsl:text>
								</xsl:if>
							</xsl:for-each>
							<xsl:text>?coin nmo:hasTypeSeriesItem ?type .</xsl:text>
							<xsl:if test="contains($constraints, 'nmo:hasCollection')">
								<xsl:analyze-string select="$constraints" regex="(nmo:hasCollection\s&lt;[^&gt;]+&gt;)">
									<xsl:matching-substring>
										<xsl:value-of select="concat('?coin ', regex-group(1), '.')"/>
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>
							<xsl:text>?coin nmo:hasMEASUREMENT ?MEASUREMENT</xsl:text>
							<xsl:text>}</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="service">
					<xsl:choose>
						<xsl:when test="string($type)">
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace(replace($query, '&lt;CONSTRAINTS&gt;', replace($replace, 'typeURI', $type)), 'MEASUREMENT', concat(upper-case(substring($measurement, 1, 1)), substring($measurement, 2))))), '&amp;output=xml')"/>
						</xsl:when>
						<xsl:when test="string($constraints)">
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace(replace($query, '&lt;CONSTRAINTS&gt;', replace($replace, '\\\\and',
								'&amp;&amp;')), 'MEASUREMENT', concat(upper-case(substring($measurement, 1, 1)), substring($measurement, 2))))), '&amp;output=xml')"/>
						</xsl:when>
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
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
