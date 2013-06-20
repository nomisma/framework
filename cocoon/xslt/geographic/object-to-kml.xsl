<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	exclude-result-prefixes="xs cinclude geo xhtml" version="2.0">
	<xsl:param name="id"/>

	<xsl:variable name="uri">
		<xsl:text>http://nomisma.org/id/</xsl:text>
		<xsl:value-of select="$id"/>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:call-template name="kml"/>
	</xsl:template>

	<xsl:template name="kml">
		<xsl:variable name="typeof" select="/xhtml:div/@typeof"/>
		
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
				<!-- display mint -->
				<xsl:choose>
					<xsl:when test="$typeof='mint'">
						<Placemark xmlns="http://earth.google.com/kml/2.0">
							<name>
								<xsl:value-of select="descendant::xhtml:div[@property='skos:prefLabel'][@xml:lang='en']"/>
							</name>
							<styleUrl>#mint</styleUrl>
							<!-- add placemark -->
							<Point>
								<coordinates>
									<xsl:value-of select="concat(descendant::*[@property='geo:long'], ',', descendant::*[@property='geo:lat'])"/>
								</coordinates>
							</Point>
						</Placemark>
						<cinclude:include src="cocoon:/widget?uri={$uri}&amp;curie={$typeof}&amp;template=kml"/>
					</xsl:when>
					<xsl:when test="$typeof='type_series_item'">
						<cinclude:include src="cocoon:/widget?uri={$uri}&amp;curie={$typeof}&amp;template=kml"/>
					</xsl:when>
					<xsl:when test="$typeof='hoard'">
						<!-- create point for findspot -->
						<Placemark xmlns="http://earth.google.com/kml/2.0">
							<name>
								<xsl:value-of select="descendant::xhtml:div[@property='skos:prefLabel'][@xml:lang='en']"/>
							</name>
							<styleUrl>#hoard</styleUrl>
							<!-- add placemark -->
							<Point>
								<coordinates>
									<xsl:value-of select="concat(descendant::*[@property='geo:long'], ',', descendant::*[@property='geo:lat'])"/>
								</coordinates>
							</Point>
						</Placemark>
						
						<!-- create points for mints -->
						<xsl:apply-templates select="descendant::xhtml:span[@rel='mint']"/>
					</xsl:when>
				</xsl:choose>
			</Document>
		</kml>
	</xsl:template>
	
	<xsl:template match="xhtml:span[@rel='mint']">
		<cinclude:include src="cocoon:/get_mint_coords?id={@resource}"/>
	</xsl:template>

</xsl:stylesheet>
