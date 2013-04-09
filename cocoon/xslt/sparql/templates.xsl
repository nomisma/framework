<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	exclude-result-prefixes="xs res" version="2.0">
	<xsl:param name="template"/>
	<xsl:param name="uri"/>
	<xsl:param name="curie"/>
	<xsl:param name="endpoint"/>
	<xsl:param name="geonames_api_key"/>
	
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>


	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$template = 'kml'">
				<xsl:call-template name="kml"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="kml">
		<xsl:variable name="query">
			<xsl:choose>
				<xsl:when test="$curie='mint'">
					<![CDATA[
					PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX dcterms:  <http://purl.org/dc/terms/>
					PREFIX nm:       <http://nomisma.org/id/>
					PREFIX owl:      <http://www.w3.org/2002/07/owl#>
					PREFIX gml: <http://www.opengis.net/gml/>
					SELECT DISTINCT ?findspot ?gml ?object ?title WHERE {
					{?type nm:mint <URI> .
					?object nm:type_series_item ?type.
					?object nm:findspot ?findspot
					} UNION {
					?object nm:mint <URI> .
					?object nm:findspot ?findspot
					OPTIONAL {?findspot gml:pos ?gml }
					}
					OPTIONAL {?object dcterms:title ?title}
					}]]>
				</xsl:when>
				<xsl:when test="$curie='type_series_item'">
					<![CDATA[
					PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX dcterms:  <http://purl.org/dc/terms/>
					PREFIX nm:       <http://nomisma.org/id/>
					PREFIX owl:      <http://www.w3.org/2002/07/owl#>
					PREFIX gml: <http://www.opengis.net/gml/>
					SELECT ?object ?findspot ?gml ?title WHERE {
					?object nm:type_series_item <URI> .
					?object nm:findspot ?findspot
					OPTIONAL {?object dcterms:title ?title}
					OPTIONAL {?findspot gml:pos ?gml }
					}
					]]>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'URI', $uri))), '&amp;output=xml')"/>

		<xsl:apply-templates select="document($service)/res:sparql" mode="kml"/>
	</xsl:template>

	<xsl:template match="res:sparql" mode="kml">
		<xsl:apply-templates select="descendant::res:result" mode="kml"/>
	</xsl:template>

	<xsl:template match="res:result" mode="kml">
		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:choose>
					<xsl:when test="res:binding[@name='title']/res:literal">
						<xsl:value-of select="res:binding[@name='title']/res:literal"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="res:binding[@name='object']/res:uri"/>
					</xsl:otherwise>
				</xsl:choose>
			</name>
			<description>
				<xsl:value-of select="res:binding[@name='object']/res:uri"/>
			</description>
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
					<xsl:choose>
						<xsl:when test="contains(res:binding[@name='findspot']/res:uri, 'geonames.org')">
							<xsl:variable name="geonameId" select="substring-before(substring-after(child::res:binding[@name='findspot']/res:uri, 'geonames.org/'), '/')"/>
							<xsl:if test="number($geonameId)">
								<xsl:variable name="geonames_data" as="element()*">
									<xml>
										<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
									</xml>
								</xsl:variable>
								<xsl:variable name="coordinates" select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
								<Point>
									<coordinates>
										<xsl:value-of select="$coordinates"/>
									</coordinates>
								</Point>
							</xsl:if>
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
				</xsl:otherwise>
			</xsl:choose>
		</Placemark>
	</xsl:template>
</xsl:stylesheet>
