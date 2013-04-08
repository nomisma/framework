<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	exclude-result-prefixes="xs res" version="2.0">
	<xsl:param name="template"/>
	<xsl:param name="uri"/>
	<xsl:param name="endpoint"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$template = 'mintToKml'">
				<xsl:call-template name="mintToKml"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="mintToKml">
		<xsl:variable name="query">
			<![CDATA[
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX owl:      <http://www.w3.org/2002/07/owl#>
			PREFIX gml: <http://www.opengis.net/gml/>
			SELECT ?object ?findspot ?gml WHERE {
			?object nm:mint <URI> .
			?object nm:findspot ?findspot
			OPTIONAL {?findspot gml:pos ?gml }
			}]]>
		</xsl:variable>

		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'URI', $uri))), '&amp;output=xml')"/>

		<xsl:apply-templates select="document($service)/res:sparql" mode="mintToKml"/>
	</xsl:template>

	<xsl:template match="res:sparql" mode="mintToKml">
		<xsl:apply-templates select="descendant::res:result"/>
	</xsl:template>

	<xsl:template match="res:result">
		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="res:binding[@name='object']/res:uri"/>
			</name>
			<styleUrl>#mapped</styleUrl>
			<!-- add placemark -->
			<xsl:choose>
				<xsl:when test="res:binding[@name='findspot']/res:literal">
					<xsl:variable name="coordinates" select="tokenize(res:binding[@name='findspot']/res:literal, ' ')"/>
					<Point>
						<coordinates>
							<xsl:value-of select="concat($coordinates[2], ',', $coordinates[1])"/>
						</coordinates>
					</Point>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="coordinates" select="tokenize(res:binding[@name='gml']/res:literal, ' ')"/>
					<Point>
						<coordinates>
							<xsl:value-of select="concat($coordinates[2], ',', $coordinates[1])"/>
						</coordinates>
					</Point>
				</xsl:otherwise>
			</xsl:choose>
		</Placemark>
	</xsl:template>
</xsl:stylesheet>
