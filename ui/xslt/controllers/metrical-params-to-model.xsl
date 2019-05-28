<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nomisma="http://nomisma.org/"
	exclude-result-prefixes="#all">
	<xsl:include href="metamodel-templates.xsl"/>
	<xsl:include href="sparql-metamodel.xsl"/>

	<!-- request parameters -->
	<xsl:param name="filter" select="doc('input:filter')/query"/>
	<xsl:param name="measurement" select="doc('input:request')/request/parameters/parameter[name = 'measurement']/value"/>
	<xsl:param name="format" select="doc('input:request')/request/parameters/parameter[name = 'format']/value"/>

	<!-- config variables -->
	<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
	<xsl:variable name="query" select="doc('input:query')"/>

	<!-- parse query statements into a data object -->
	<xsl:variable name="statements" as="element()*">
		<statements>
			<union>
				<group>
					<xsl:call-template name="nomisma:filterToMetamodel">
						<xsl:with-param name="subject">?coinType</xsl:with-param>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
					
					<!-- include all coins related to the type and skos:exactMatch types -->
					<union>
						<group>
							<triple s="?coin" p="nmo:hasTypeSeriesItem" o="?coinType"/>
						</group>
						<group>
							<triple s="?coinType" p="skos:exactMatch" o="?match"/>
							<triple s="?coin" p="nmo:hasTypeSeriesItem" o="?match"/>						
						</group>					
					</union>
				</group>
				<group>
					<xsl:call-template name="nomisma:filterToMetamodel">
						<xsl:with-param name="subject">?coin</xsl:with-param>
						<xsl:with-param name="filter" select="$filter"/>
					</xsl:call-template>
				</group>
			</union>
			<!-- parse measurement -->
			<triple s="?coin" p="{$measurement}" o="?measurement"/>
		</statements>
	</xsl:variable>

	<xsl:variable name="statementsSPARQL">
		<xsl:apply-templates select="$statements/*"/>
	</xsl:variable>

	<xsl:variable name="service">
		<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>
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
