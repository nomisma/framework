<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:gml="http://www.opengis.net/gml" xmlns:skos="http://www.w3.org/2008/05/skos#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nuds="http://nomisma.org/nuds" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs gml exsl skos rdf xlink nuds" xmlns="http://earth.google.com/kml/2.0" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>

	<xsl:template match="/">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<Style xmlns="" id="mint">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/pal4/icon48.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style xmlns="" id="hoard">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/pal4/icon49.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style xmlns="" id="mapped">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/pal4/icon57.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<xsl:choose>
					<xsl:when test="count(/*[local-name()='nuds']) &gt; 0">
						<xsl:call-template name="nuds"/>
					</xsl:when>
					<xsl:when test="count(/*[local-name()='nudsHoard']) &gt; 0">
						<xsl:call-template name="nudsHoard"/>
					</xsl:when>
				</xsl:choose>
			</Document>
		</kml>

	</xsl:template>

	<xsl:template name="nuds">
		<xsl:apply-templates select="/nuds:nuds"/>
	</xsl:template>

	<xsl:template name="nudsHoard">
		<xsl:apply-templates select="/nudsHoard"/>
	</xsl:template>

	<xsl:template match="nudsHoard">
		<xsl:for-each select="descendant::geogname[@xlink:role='findspot'][string(@xlink:href)]">
			<Placemark id="{@xlink:href}">
				<name>
					<xsl:value-of select="."/>
				</name>
				<styleUrl>#hoard</styleUrl>
				<xsl:call-template name="getPlacemark">
					<xsl:with-param name="href" select="@xlink:href"/>
				</xsl:call-template>
			</Placemark>
		</xsl:for-each>
		<xsl:apply-templates select="descendant::*[local-name()='typeDesc']"/>
	</xsl:template>

	<xsl:template match="*[local-name()='typeDesc']">
		<xsl:variable name="typeDesc_resource" select="@xlink:href"/>
		<xsl:variable name="typeDesc">
			<xsl:choose>
				<xsl:when test="string($typeDesc_resource)">
					<xsl:copy-of select="document(concat($typeDesc_resource, '.xml'))/nuds:nuds/nuds:descMeta/nuds:typeDesc"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:for-each select="exsl:node-set($typeDesc)/descendant::*[local-name()='geogname'][@xlink:role='mint'][string(@xlink:href)]">
			<Placemark id="{@xlink:href}">
				<name>
					<xsl:value-of select="."/>
				</name>
				<styleUrl>#mapped</styleUrl>
				<xsl:call-template name="getPlacemark">
					<xsl:with-param name="href" select="@xlink:href"/>
				</xsl:call-template>
			</Placemark>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<xsl:for-each select="descendant::nuds:geogname[@xlink:role='mint'][string(@xlink:href)]">
			<Placemark id="{@xlink:href}">
				<name>
					<xsl:value-of select="."/>
				</name>
				<styleUrl>#mint</styleUrl>
				<xsl:call-template name="getPlacemark">
					<xsl:with-param name="href" select="@xlink:href"/>
				</xsl:call-template>
			</Placemark>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="getPlacemark">
		<xsl:param name="href"/>

		<xsl:choose>
			<xsl:when test="contains($href, 'geonames')">
				<xsl:variable name="geonameId" select="substring-before(substring-after($href, 'geonames.org/'), '/')"/>
				<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
				<xsl:variable name="coordinates" select="concat(exsl:node-set($geonames_data)//lng, ',', exsl:node-set($geonames_data)//lat)"/>
				<Point>
					<coordinates>
						<xsl:value-of select="$coordinates"/>
					</coordinates>
				</Point>
			</xsl:when>
			<xsl:when test="contains($href, 'nomisma')">
				<xsl:variable name="rdf_url" select="concat('http://nomisma.org/cgi-bin/RDFa.py?uri=', encode-for-uri($href))"/>
				<xsl:variable name="nomisma_data" select="document($rdf_url)"/>
				<xsl:variable name="coordinates" select="exsl:node-set($nomisma_data)//*[local-name()='pos']"/>
				<!--<description>
					<xsl:copy-of select="document($href)//div[@id='source']"/>
				</description>-->
				<xsl:if test="string($coordinates)">
					<xsl:variable name="lat" select="substring-before($coordinates, ' ')"/>
					<xsl:variable name="lon" select="substring-after($coordinates, ' ')"/>
					<Point>
						<coordinates>
							<xsl:value-of select="concat($lon, ',', $lat)"/>
						</coordinates>
					</Point>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
