<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2005/Atom" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common"
	xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml" exclude-result-prefixes="xs exsl" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'nomisma/config.xml'))"/>
	<xsl:variable name="solr-url" select="concat(exsl:node-set($config)/config/solr_url, 'select/')"/>
	<!-- request URL -->
	<xsl:param name="base-url" select="substring-before(doc('input:url')/request/request-url, 'feed/')"/>

	<xsl:param name="q">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
	</xsl:param>
	<xsl:param name="start">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='start']/value"/>
	</xsl:param>
	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="service">
		<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;sort=timestamp%20desc&amp;start=',$start, '&amp;rows=100')"/>
	</xsl:variable>
	<xsl:param name="rows" as="xs:integer">100</xsl:param>



	<xsl:template match="/">
		<xsl:variable name="numFound">
			<xsl:value-of select="number(//result[@name='response']/@numFound)"/>
		</xsl:variable>
		<xsl:variable name="last" select="number(concat(substring($numFound, 1, string-length($numFound) - 2), '00'))"/>
		<xsl:variable name="next" select="$start_var + 100"/>


		<feed xmlns="http://www.w3.org/2005/Atom" xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml">
			<title>nomisma.org</title>
			<link href="/"/>
			<link href="../feed/q={$q}" rel="self"/>
			<id>nomisma.org</id>
			<xsl:if test="not($next = $last)">
				<link rel="next" href="{$base-url}feed/?q={$q}&amp;start={$next}"/>
			</xsl:if>
			<link rel="last" href="{$base-url}feed/?q={$q}&amp;start={$last}"/>
			<author>
				<name>nomisma.org</name>
			</author>
			<xsl:apply-templates select="document($service)/descendant::doc"/>
		</feed>

	</xsl:template>

	<xsl:template match="doc">
		<entry>
			<title>
				<xsl:value-of select="str[@name='prefLabel']"/>
			</title>
			<link href="{$base-url}id/{str[@name='id']}"/>
			<link rel="alternate xml" type="application/rdf+xml" href="{$base-url}id/{str[@name='id']}.rdf"/>
			<xsl:if test="str[@name='typeof'] = 'hoard' or str[@name='typeof'] = 'type_series_item'">
				<link rel="alternate xml" type="text/xml" href="{$base-url}xml/{str[@name='id']}"/>
			</xsl:if>			
			<xsl:if test="str[@name='typeof'] = 'hoard' or str[@name='typeof'] = 'type_series_item' or str[@name='typeof'] = 'mint'">
				<link rel="alternate xml" type="application/vnd.google-earth.kml+xml" href="{$base-url}id/{str[@name='id']}.kml"/>
			</xsl:if>
			
			<id>
				<xsl:text>http://nomisma.org/id/</xsl:text>
				<xsl:value-of select="str[@name='id']"/>
			</id>
			
			<updated>
				<xsl:value-of select="date[@name='timestamp']"/>
			</updated>
			<xsl:if test="count(str[@name='pos']) &gt; 0">
				<georss:where>
					<gml:Point>
						<gml:pos>
							<xsl:value-of select="str[@name='pos']"/>
						</gml:pos>
					</gml:Point>
				</georss:where>
			</xsl:if>
		</entry>
	</xsl:template>
</xsl:stylesheet>
