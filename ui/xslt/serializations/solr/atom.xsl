<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2005/Atom" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- config variable -->
	<xsl:variable name="url" select="/content/config/url"/>

	<!-- request params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="start" select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:param name="rows" as="xs:integer">100</xsl:param>

	<xsl:template match="/">
		<xsl:variable name="numFound">
			<xsl:value-of select="number(//result[@name='response']/@numFound)"/>
		</xsl:variable>
		<xsl:variable name="last" select="floor($numFound div 100) * 100"/>
		<xsl:variable name="next" select="$start_var + 100"/>


		<feed xmlns="http://www.w3.org/2005/Atom">
			<title>nomisma.org</title>
			<id>
				<xsl:value-of select="$url"/>
			</id>
			<link href="{$url}"/>
			<link href="{$url}feed{if (string($q)) then concat('?q=', $q) else ''}" rel="self"/>
			<xsl:if test="$next &lt; $last">
				<link rel="next" href="{$url}feed{if (string($q)) then concat('?q=', $q, '&amp;') else '?'}start={$next}"/>
			</xsl:if>
			<link rel="last" href="{$url}feed{if (string($q)) then concat('?q=', $q, '&amp;') else '?'}start={$last}"/>
			<author>
				<name>nomisma.org</name>
			</author>
			<xsl:apply-templates select="descendant::doc"/>
		</feed>

	</xsl:template>

	<xsl:template match="doc">
		<entry>
			<title>
				<xsl:value-of select="str[@name='prefLabel']"/>
			</title>
			<summary>
				<xsl:value-of select="str[@name='definition']"/>
			</summary>
			<link href="{$url}id/{str[@name='id']}"/>
			<link rel="rdf/xml" type="application/rdf+xml" href="{$url}id/{str[@name='id']}.rdf"/>
			<link rel="rdf/ttl" type="text/turte" href="{$url}id/{str[@name='id']}.ttl"/>
			<link rel="json-ld" type="application/json" href="{$url}id/{str[@name='id']}.jsonld"/>
			<id>
				<xsl:value-of select="str[@name='id']"/>
			</id>
			<updated>
				<xsl:value-of select="date[@name='timestamp']"/>
			</updated>
		</entry>
	</xsl:template>
</xsl:stylesheet>
