<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" exclude-result-prefixes="#all" version="2.0">

	<xsl:variable name="id" select="substring-after(//@rdf:about, 'id/')"/>
	<xsl:variable name="uri">
		<xsl:text>http://nomisma.org/id/</xsl:text>
		<xsl:value-of select="$id"/>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/rdf:RDF/*" mode="root"/>
	</xsl:template>

	<xsl:template match="*" mode="root">
		<xsl:variable name="type" select="name()"/>

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
					<xsl:when test="$type='nm:mint'">
						<Placemark xmlns="http://earth.google.com/kml/2.0">
							<name>
								<xsl:value-of select="descendant::skos:prefLabel[@xml:lang='en']"/>
							</name>
							<description>
								<![CDATA[
								<dl class="dl-horizontal"><dt>Latitude</dt><dd>]]><xsl:value-of select="descendant::geo:lat"/><![CDATA[</dd>
								<dt>Longitude</dt><dd>]]><xsl:value-of select="descendant::geo:long"/><![CDATA[</dd>
								<![CDATA[</dl>]]>
							</description>
							<styleUrl>#mint</styleUrl>
							<!-- add placemark -->
							<Point>
								<coordinates>
									<xsl:value-of select="concat(descendant::geo:long, ',', descendant::geo:lat)"/>
								</coordinates>
							</Point>
						</Placemark>
						<xsl:variable name="service" select="concat(/content/config/url, 'apis/getKml?uri=', $uri, '&amp;curie=', $type)"/>
						<xsl:copy-of select="document($service)//*[local-name()='Placemark']"/>
					</xsl:when>
					<xsl:when test="$type='nm:type_series_item'">
						<!-- create point for mints -->
						<xsl:apply-templates select="descendant::nm:mint[string(@rdf:resource)]">
							<xsl:with-param name="style">hoard</xsl:with-param>
						</xsl:apply-templates>
						<xsl:variable name="service" select="concat(/content/config/url, 'apis/getKml?uri=', $uri, '&amp;curie=', $type)"/>
						<xsl:copy-of select="document($service)//*[local-name()='Placemark']"/>
					</xsl:when>
					<xsl:when test="$type='nm:hoard'">
						<Placemark xmlns="http://earth.google.com/kml/2.0">
							<name>
								<xsl:value-of select="descendant::skos:prefLabel[@xml:lang='en']"/>
							</name>
							<description>
								<![CDATA[
								<dl class="dl-horizontal"><dt>Latitude</dt><dd>]]><xsl:value-of select="descendant::geo:lat"/><![CDATA[</dd>
								<dt>Longitude</dt><dd>]]><xsl:value-of select="descendant::geo:long"/><![CDATA[</dd>
								<![CDATA[</dl>]]>
							</description>
							<styleUrl>#hoard</styleUrl>
							<!-- add placemark -->
							<Point>
								<coordinates>
									<xsl:value-of select="concat(descendant::geo:long, ',', descendant::geo:lat)"/>
								</coordinates>
							</Point>
						</Placemark>
					</xsl:when>
				</xsl:choose>
			</Document>
		</kml>
	</xsl:template>
</xsl:stylesheet>
