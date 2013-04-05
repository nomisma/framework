<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nuds="http://nomisma.org/id/nuds" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:output method="xml" encoding="UTF-8" media-type="application/vnd.google-earth.kml+xml"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/xhtml:div"/>
	</xsl:template>

	<xsl:template match="xhtml:div">
		<xsl:variable name="pos">
			<xsl:choose>
				<xsl:when test="string(descendant::*[@property='gml:pos'])">
					<xsl:value-of select="descendant::*[@property='gml:pos']"/>
				</xsl:when>
				<xsl:when test="string(descendant::*[@property='nm:findspot']/@content)">
					<xsl:value-of select="descendant::*[@property='nm:findspot']/@content"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="style">
			<xsl:choose>
				<xsl:when test="@typeof='nm:mint'">
					<xsl:text>#mint</xsl:text>
				</xsl:when>
				<xsl:when test="@typeof='nm:hoard'">
					<xsl:text>#hoard</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="lat" select="substring-before($pos, ' ')"/>
		<xsl:variable name="lon" select="substring-after($pos, ' ')"/>

		<kml xmlns="http://www.opengis.net/kml/2.2">
			<Document>
				<Style id="mint">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/pal4/icon48.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="hoard">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/pal4/icon49.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="mapped">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/pal4/icon57.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Placemark>
					<name>
						<xsl:value-of select="xhtml:div[@property='skos:prefLabel'][@xml:lang='en']"/>
					</name>
					<styleUrl>
						<xsl:value-of select="$style"/>
					</styleUrl>
					<description><!--<xsl:value-of select="'&lt;![CDATA['"/><xsl:copy-of select="."/><xsl:text>]]&gt;</xsl:text>--></description>
					<Point>
						<coordinates><xsl:value-of select="$lon"/>,<xsl:value-of select="$lat"/>,0</coordinates>
					</Point>
				</Placemark>
			</Document>
		</kml>
	</xsl:template>
</xsl:stylesheet>
