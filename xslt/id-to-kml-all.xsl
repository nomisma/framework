<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nuds="http://nomisma.org/id/nuds" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:output method="xml" encoding="UTF-8" media-type="application/vnd.google-earth.kml+xml"/>


	<xsl:template match="/">
		<kml xmlns="http://www.opengis.net/kml/2.2">
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
				<xsl:apply-templates select="descendant::point"/>
			</Document>
		</kml>


	</xsl:template>

	<xsl:template match="point">
		<xsl:if test="string(pos)">
			<xsl:variable name="lat" select="substring-before(pos, ' ')"/>
			<xsl:variable name="lon" select="substring-after(pos, ' ')"/>
			<Placemark>
				<name>
					<xsl:value-of select="id"/>
				</name>
				<styleUrl>#mapped</styleUrl>
				<description><!--<xsl:value-of select="'&lt;![CDATA['"/><xsl:copy-of select="."/><xsl:text>]]&gt;</xsl:text>--></description>
				<Point>
					<coordinates><xsl:value-of select="$lon"/>,<xsl:value-of select="$lat"/>,0</coordinates>
				</Point>
			</Placemark>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
