<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nomisma="http://nomisma.org/"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all">
	<xsl:include href="metamodel-templates.xsl"/>
	<xsl:include href="sparql-metamodel.xsl"/>

	<!-- request parameters -->
	<xsl:param name="filter" select="doc('input:request')/request/parameters/parameter[name = 'filter']/value"/>
	<xsl:param name="facet" select="doc('input:request')/request/parameters/parameter[name = 'facet']/value"/>

	<!-- config variables -->
	<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
	<xsl:variable name="query" select="doc('input:query')"/>

	<xsl:variable name="statements" as="element()*">
		<statements>
			<triple s="?coinType" p="rdf:type" o="nmo:TypeSeriesItem"/>

			<!-- parse filters -->
			<xsl:call-template name="nomisma:filterToMetamodel">
				<xsl:with-param name="subject">?coinType</xsl:with-param>
				<xsl:with-param name="filter" select="$filter"/>
			</xsl:call-template>

			<!-- facet -->
			<xsl:call-template name="nomisma:distToMetamodel">
				<xsl:with-param name="object">?facet</xsl:with-param>
				<xsl:with-param name="dist" select="$facet"/>
			</xsl:call-template>
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
