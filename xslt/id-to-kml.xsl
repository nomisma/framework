<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nm="http://nomisma.org/id/" xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:exsl="http://exslt.org/common" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:skos="http://www.w3.org/2008/05/skos#"
	xmlns:numishare="http://code.google.com/p/numishare/" xmlns:nuds="http://nomisma.org/id/nuds" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gml="http://www.opengis.net/gml/" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>


	<xsl:template match="/">		
		<xsl:apply-templates select="rdf:RDF"/>
	</xsl:template>
	
	<xsl:template match="rdf:RDF">
		<xsl:variable name="lat" select="substring-before(//gml:pos, ' ')"/>
		<xsl:variable name="lon" select="substring-after(//gml:pos, ' ')"/>
		
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
				<Placemark>
					<name><xsl:value-of select="skos:Concept/skos:prefLabel[@xml:lang='en']"/></name>
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
