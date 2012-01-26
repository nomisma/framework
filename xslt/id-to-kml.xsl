<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>	


	<xsl:template match="/">
		<xsl:variable name="id" select="substring-before(tokenize(doc('input:request')/request/request-url, '/')[last()], '.kml')"/>
		<xsl:apply-templates select="document(concat($exist-url, 'nomisma/id/', $id, '.xml'))/div"/>
	</xsl:template>
	
	<xsl:template match="div">
		<xsl:variable name="lat" select="substring-before(//span[@property='gml:pos'], ' ')"/>
		<xsl:variable name="lon" select="substring-after(//span[@property='gml:pos'], ' ')"/>
		
		<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:h="http://www.w3.org/1999/xhtml">
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
				<Placemark>
					<name><xsl:value-of select="div[@property='skos:prefLabel']"/></name>
					<styleUrl>#mint</styleUrl>
					<description><!--<xsl:value-of select="'&lt;![CDATA['"/><xsl:copy-of select="."/><xsl:text>]]&gt;</xsl:text>--></description>
					<Point>
						<coordinates><xsl:value-of select="$lon"/>,<xsl:value-of select="$lat"/>,0</coordinates>
					</Point>
				</Placemark>
			</Document>
		</kml>
	</xsl:template>



</xsl:stylesheet>
