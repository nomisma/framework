<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" exclude-result-prefixes="#all"
	xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:kml="http://earth.google.com/kml/2.0" version="2.0">

	<xsl:variable name="id" select="substring-after(//rdf:RDF/*[1]/@rdf:about, 'id/')"/>
	<xsl:variable name="uri">
		<xsl:text>http://nomisma.org/id/</xsl:text>
		<xsl:value-of select="$id"/>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/rdf:RDF"/>
	</xsl:template>

	<xsl:template match="rdf:RDF">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<Style id="mint">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="findspot">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/intl/en_us/mapfiles/ms/micons/red-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="polygon">
					<PolyStyle>
						<color>50F00014</color>
						<outline>1</outline>
					</PolyStyle>
				</Style>

				<xsl:apply-templates select="nm:mint|nm:region|nm:hoard">
					<xsl:with-param name="lat">
						<xsl:value-of select="geo:SpatialThing/geo:lat"/>
					</xsl:with-param>
					<xsl:with-param name="long">
						<xsl:value-of select="geo:SpatialThing/geo:long"/>
					</xsl:with-param>
					<xsl:with-param name="polygon">
						<xsl:value-of select="geo:SpatialThing/osgeo:asGeoJSON"/>
					</xsl:with-param>
				</xsl:apply-templates>
			</Document>
		</kml>
	</xsl:template>

	<xsl:template match="nm:hoard|nm:mint|nm:region">
		<xsl:param name="lat"/>
		<xsl:param name="long"/>
		<xsl:param name="polygon"/>
		<xsl:variable name="type" select="name()"/>

		<xsl:if test="(string($lat) and string($long)) or string($polygon)">
			<Placemark xmlns="http://earth.google.com/kml/2.0">
				<name>
					<xsl:value-of select="skos:prefLabel[@xml:lang='en']"/>
				</name>

				<xsl:choose>
					<xsl:when test="string($lat) and string($long)">
						<xsl:choose>
							<xsl:when test="$type='nm:mint' or $type='nm:region'">
								<styleUrl>#mint</styleUrl>
							</xsl:when>
							<xsl:when test="$type='nm:hoard'">
								<styleUrl>#findspot</styleUrl>
							</xsl:when>
						</xsl:choose>
						<Point>
							<coordinates>
								<xsl:value-of select="concat($long, ',', $lat)"/>
							</coordinates>
						</Point>
					</xsl:when>
					<xsl:when test="string($polygon)">
						<styleUrl>#polygon</styleUrl>
						<Polygon>
							<outerBoundaryIs>
								<LinearRing>
									<coordinates>
										<xsl:analyze-string regex="\[(\d[^\]]+)\]" select="$polygon">
											<xsl:matching-substring>
												<xsl:for-each select="regex-group(1)">
													<xsl:value-of select="normalize-space(tokenize(., ',')[1])"/>
													<xsl:text>, </xsl:text>
													<xsl:value-of select="normalize-space(tokenize(., ',')[2])"/>
													<xsl:text>, 0. </xsl:text>
												</xsl:for-each>
											</xsl:matching-substring>
										</xsl:analyze-string>
										<!--135.2, 35.4, 0. 135.4, 35.6, 0. 135.2, 35.6, 0. 135.2, 35.4, 0. -->
									</coordinates>
								</LinearRing>
							</outerBoundaryIs>
						</Polygon>
					</xsl:when>
				</xsl:choose>
			</Placemark>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
