<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="#all" version="2.0">

	<xsl:param name="api" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
	<xsl:param name="findType" select="if ($api = 'getFindspots') then 'find' else if ($api='getHoards') then 'hoard' else ''"/>

	<xsl:template match="/*[1]">
		<xsl:choose>
			<xsl:when test="namespace-uri() = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'">
				<xsl:choose>
					<xsl:when test="geo:SpatialThing/osgeo:asGeoJSON">
						<xsl:apply-templates select="geo:SpatialThing" mode="poly">
							<xsl:with-param name="label" select="*[1]/skos:prefLabel[@xml:lang='en']"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="geo:SpatialThing/geo:lat and geo:SpatialThing/geo:long">
						<xsl:apply-templates select="geo:SpatialThing" mode="point">
							<xsl:with-param name="label" select="*[1]/skos:prefLabel[@xml:lang='en']"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>{}</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="namespace-uri() = 'http://www.w3.org/2005/sparql-results#'">
				<xsl:choose>
					<xsl:when test="count(descendant::res:result) &gt; 0">
						<xsl:text>{"type": "FeatureCollection","features": [</xsl:text>
						<xsl:apply-templates select="descendant::res:result"/>
						<xsl:text>]}</xsl:text>
					</xsl:when>
					<xsl:otherwise>{}</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>{}</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="geo:SpatialThing" mode="point">
		<xsl:param name="label"/>
		
		<xsl:text>{"type": "Feature","geometry": {"type": "Point","coordinates": [</xsl:text>
		<xsl:value-of select="geo:long"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="geo:lat"/>
		<xsl:text>]},"properties": {"name": "</xsl:text>
		<xsl:value-of select="$label"/>
		<xsl:text>","type": "</xsl:text>
		<xsl:value-of select="lower-case(parent::node()/*[1]/local-name())"/>
		<xsl:text>"</xsl:text>
		<xsl:text>}}</xsl:text>
		
	</xsl:template>
	
	<xsl:template match="geo:SpatialThing" mode="poly">
		<xsl:param name="label"/>
		
		<xsl:text>{"type": "Feature","geometry":</xsl:text>
		<xsl:value-of select="osgeo:asGeoJSON"/>
		<xsl:text>,"properties": {"name": "</xsl:text>
		<xsl:value-of select="$label"/>
		<xsl:text>","type": "</xsl:text>
		<xsl:value-of select="lower-case(parent::node()/*[1]/local-name())"/>
		<xsl:text>"</xsl:text>
		<xsl:text>}}</xsl:text>		
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:choose>
			<xsl:when test="res:binding[@name='poly']">
				<xsl:text>{"type": "Feature","geometry":</xsl:text>
				<xsl:value-of select="res:binding[@name='poly']/res:literal"/>
				<xsl:text>,"properties": {"name": "</xsl:text>
				<xsl:value-of select="res:binding[@name='label']/res:literal"/>
				<xsl:text>", "uri": "</xsl:text>
				<xsl:value-of select="res:binding[@name='place']/res:uri"/>
				<xsl:text>","type": "</xsl:text>
				<xsl:value-of select="if ($api = 'getMints') then 'region' else $findType"/>
				<xsl:text>"</xsl:text>
				<xsl:text>}}</xsl:text>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"type": "Feature","geometry": {"type": "Point","coordinates": [</xsl:text>
				<xsl:value-of select="res:binding[@name='long']/res:literal"/>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="res:binding[@name='lat']/res:literal"/>
				<xsl:text>]},"properties": {"name": "</xsl:text>
				<xsl:value-of select="if (res:binding[@name='hoardLabel']/res:literal) then res:binding[@name='hoardLabel']/res:literal else res:binding[@name='label']/res:literal"/>
				<xsl:text>", "uri": "</xsl:text>
				<xsl:value-of select="if (res:binding[@name='hoard']/res:uri) then res:binding[@name='hoard']/res:uri else res:binding[@name='place']/res:uri"/>
				<xsl:text>","type": "</xsl:text>
				<xsl:value-of select="if ($api = 'getMints') then 'mint' else $findType"/>
				<xsl:text>"</xsl:text>
				<xsl:if test="$findType = 'hoard' and res:binding[@name='place']/res:uri">
					<xsl:text>,"place":"</xsl:text>
					<xsl:value-of select="res:binding[@name='label']/res:literal"/>
					<xsl:text>","placeUri":"</xsl:text>
					<xsl:value-of select="res:binding[@name='place']/res:uri"/>
					<xsl:text>"</xsl:text>
				</xsl:if>				
				<xsl:text>}}</xsl:text>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
