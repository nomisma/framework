<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://earth.google.com/kml/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:kml="http://earth.google.com/kml/2.0"
	xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="xsl xs dcterms res nm rdf rdfs skos foaf geo osgeo nmo kml saxon" version="2.0">

	<!--<xsl:variable name="id" select="tokenize(//rdf:RDF/*[1]/@rdf:about, '/')[last()]"/>
	<xsl:variable name="type" select="/content/rdf:RDF/*[1]/name()"/>-->

	<xsl:output name="html" encoding="UTF-8" method="html" exclude-result-prefixes="#all"/>

	<xsl:template match="/">
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
				<Style id="hoard">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/intl/en_us/mapfiles/ms/micons/red-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="findspot">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/intl/en_us/mapfiles/ms/micons/orange-dot.png</href>
						</Icon>
					</IconStyle>
				</Style>
				<Style id="polygon">
					<PolyStyle>
						<color>50F00014</color>
						<outline>1</outline>
					</PolyStyle>
				</Style>

				<xsl:apply-templates select="doc('input:mints')/*">
					<xsl:with-param name="type">mint</xsl:with-param>
				</xsl:apply-templates>
				<xsl:apply-templates select="doc('input:hoards')/res:sparql">
					<xsl:with-param name="type">hoard</xsl:with-param>
				</xsl:apply-templates>
				<xsl:apply-templates select="doc('input:findspots')/res:sparql">
					<xsl:with-param name="type">findspot</xsl:with-param>
				</xsl:apply-templates>
			</Document>
		</kml>
	</xsl:template>

	<!-- RDF/XML template for mint -->
	<xsl:template match="rdf:RDF">
		<xsl:choose>
			<xsl:when test="descendant::geo:SpatialThing/osgeo:asGeoJSON">
				<!--<xsl:apply-templates select="descendant::geo:SpatialThing" mode="poly">
					<xsl:with-param name="uri" select="*[1]/@rdf:about"/>
					<xsl:with-param name="type" select="*[1]/name()"/>
					<xsl:with-param name="label" select="*[1]/skos:prefLabel[@xml:lang = 'en']"/>
				</xsl:apply-templates>-->
			</xsl:when>
			<xsl:when test="descendant::geo:SpatialThing[geo:lat and geo:long]">
				<xsl:apply-templates select="descendant::geo:SpatialThing" mode="point">
					<xsl:with-param name="uri" select="*[1]/@rdf:about"/>
					<xsl:with-param name="label" select="*[1]/skos:prefLabel[@xml:lang = 'en']"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- generate GeoJSON for id/ responses -->
	<xsl:template match="geo:SpatialThing" mode="point">
		<xsl:param name="uri"/>
		<xsl:param name="type"/>
		<xsl:param name="label"/>

		<Placemark>
			<name>
				<xsl:value-of select="$label"/>
			</name>
			<description>
				<xsl:variable name="description" as="node()*">
					<div xmlns="">
						<b>Place: </b>
						<a href="{$uri}">
							<xsl:value-of select="$label"/>
						</a>
					</div>
				</xsl:variable>

				<xsl:value-of select="saxon:serialize($description, 'html')"/>
			</description>
			<styleUrl>
				<xsl:choose>
					<xsl:when test="$type = 'nmo:Hoard'">#hoard</xsl:when>
					<xsl:otherwise>#mint</xsl:otherwise>
				</xsl:choose>
			</styleUrl>

			<Point>
				<coordinates>
					<xsl:value-of select="concat(geo:long, ',', geo:lat)"/>
				</coordinates>
			</Point>
		</Placemark>

	</xsl:template>

	<xsl:template match="res:result">
		<xsl:param name="type"/>


		<Placemark>
			<name>
				<xsl:value-of
					select="
						if (res:binding[@name = 'hoardLabel']/res:literal) then
							res:binding[@name = 'hoardLabel']/res:literal
						else
							res:binding[@name = 'label']/res:literal"
				/>
			</name>
			<description>

				<xsl:variable name="description" as="node()*">
					<div xmlns="">
						<xsl:if test="res:binding[@name = 'hoard']">
							<b>Hoard: </b>
							<a href="{res:binding[@name = 'hoard']/res:uri}">
								<xsl:value-of select="res:binding[@name = 'hoardLabel']/res:literal"/>
							</a>
							<br/>
						</xsl:if>
						<b>Place: </b>
						<a href="{res:binding[@name = 'place']/res:uri}">
							<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
						</a>
					</div>
				</xsl:variable>

				<xsl:value-of select="saxon:serialize($description, 'html')"/>
			</description>
			<styleUrl>
				<xsl:value-of select="concat('#', $type)"/>
			</styleUrl>

			<xsl:choose>
				<xsl:when test="res:binding[@name = 'poly'] or res:binding[@name = 'wkt'][contains(res:literal, 'POLYGON')]"> </xsl:when>
				<xsl:otherwise>
					<Point>
						<coordinates>
							<xsl:value-of select="concat(res:binding[@name = 'long']/res:literal, ',', res:binding[@name = 'lat']/res:literal)"/>
						</coordinates>
					</Point>
				</xsl:otherwise>
			</xsl:choose>


		</Placemark>
	</xsl:template>
</xsl:stylesheet>
