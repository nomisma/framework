<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:georss="http://www.georss.org/georss"
	xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" exclude-result-prefixes="xs" version="2.0">
	<!-- url params -->
	<xsl:param name="q"/>
	<xsl:param name="start"/>
	<xsl:param name="format"/>
	<xsl:param name="sort"/>



	<xsl:template match="/">
		<!-- other variables -->
		<xsl:variable name="rows" as="xs:integer">100</xsl:variable>
		<xsl:variable name="start_var" as="xs:integer">
			<xsl:choose>
				<xsl:when test="number($start)">
					<xsl:value-of select="$start"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="numFound">
			<xsl:value-of select="number(//result[@name='response']/@numFound)"/>
		</xsl:variable>
		<xsl:variable name="last" select="number($numFound - ($numFound mod 100))"/>
		<xsl:variable name="next" select="$start_var + 100"/>

		<!-- create sort parameter if there is string($sort) -->
		<xsl:variable name="sortParam">
			<xsl:if test="string($sort)">
				<xsl:text>&amp;sort=</xsl:text>
				<xsl:value-of select="$sort"/>
			</xsl:if>
		</xsl:variable>

		<feed xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:georss="http://www.georss.org/georss" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:gx="http://www.google.com/kml/ext/2.2"
			xmlns="http://www.w3.org/2005/Atom">
			<title>
				<xsl:value-of select="/content/config/title"/>
			</title>
			<id>http://nomisma.org/</id>
			<link rel="self" type="application/atom+xml" href="http://nomisma.org/feed/?q={$q}&amp;start={$start_var}{$sortParam}"/>
			<xsl:if test="$next != $last">
				<link rel="next" type="application/atom+xml" href="http://nomisma.org/feed/?q={$q}&amp;start={$next}{$sortParam}"/>
			</xsl:if>
			<link rel="last" type="application/atom+xml" href="http://nomisma.org/feed/?q={$q}&amp;start={$last}{$sortParam}"/>
			<link rel="search" type="application/opensearchdescription+xml" href="http://nomisma.org/opensearch.xml"/>
			<author>
				<name>
					<xsl:value-of select="//config/templates/publisher"/>
				</name>
			</author>
			<!-- opensearch results -->
			<opensearch:totalResults>
				<xsl:value-of select="$numFound"/>
			</opensearch:totalResults>
			<opensearch:startIndex>
				<xsl:value-of select="$start_var"/>
			</opensearch:startIndex>
			<opensearch:itemsPerPage>
				<xsl:value-of select="$rows"/>
			</opensearch:itemsPerPage>
			<opensearch:Query role="request" searchTerms="{$q}" startPage="{$start_var}"/>

			<xsl:apply-templates select="descendant::doc"/>
		</feed>
	</xsl:template>

	<xsl:template match="doc">
		<entry xmlns="http://www.w3.org/2005/Atom">
			<title>
				<xsl:choose>
					<xsl:when test="string(str[@name='prefLabel'])">
						<xsl:value-of select="str[@name='prefLabel']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="str[@name='id']"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<link href="http://nomisma.org/id/{str[@name='id']}"/>
			<id>
				<xsl:value-of select="str[@name='id']"/>
			</id>
			<updated>
				<xsl:value-of select="date[@name='timestamp']"/>
			</updated>
			<content>
				<xsl:value-of select="str[@name='definition']"/>
			</content>
			<link rel="alternate rdf" type="application/rdf+xml" href="http://nomisma.org/id/{str[@name='id']}.rdf"/>
		</entry>
	</xsl:template>

</xsl:stylesheet>
