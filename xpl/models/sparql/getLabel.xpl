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
				<xsl:include href="../../../ui/xslt/controllers/sparql-metamodel.xsl"/>

				<!-- request parameters -->
				<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>
				<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>

				<xsl:variable name="lang" select="if (string($langParam)) then $langParam else 'en'"/>
				<xsl:variable name="prop" select="if (matches($uri, 'https?://')) then concat('&lt;', $uri, '&gt;') else $uri"/>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>

				<xsl:variable name="query"><![CDATA[
PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>						
SELECT ?label ?en_label WHERE {
%STATEMENTS%
}]]></xsl:variable>

				<!-- parse query statements into a data object -->
				<xsl:variable name="statements" as="element()*">
					<statements>
						<xsl:choose>
							<xsl:when test="not($lang = 'en')">
								<optional>
									<triple s="{$prop}" p="skos:prefLabel" o="?label" filter="langMatches(lang(?label), &#x022;{$lang}&#x022;)"/>
								</optional>
								<triple s="{$prop}" p="skos:prefLabel" o="?en_label" filter="langMatches(lang(?en_label), &#x022;en&#x022;)"/>
							</xsl:when>
							<xsl:otherwise>
								<triple s="{$prop}" p="skos:prefLabel" o="?label" filter="langMatches(lang(?label), &#x022;en&#x022;)"/>
							</xsl:otherwise>
						</xsl:choose>
					</statements>
				</xsl:variable>

				<xsl:variable name="statementsSPARQL">
					<xsl:apply-templates select="$statements/*"/>
				</xsl:variable>

				<xsl:variable name="service">
					<xsl:value-of
						select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>
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
