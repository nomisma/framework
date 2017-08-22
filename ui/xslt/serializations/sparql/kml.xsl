<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nomisma="http://nomisma.org/"
	xmlns:kml="http://earth.google.com/kml/2.0" exclude-result-prefixes="#all" version="2.0">

	<xsl:param name="api" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
	<xsl:param name="query" select="doc('input:request')/request/parameters/parameter[name = 'query']/value"/>

	<xsl:template match="/*[1]">
		<xsl:choose>
			<xsl:when test="namespace-uri() = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'">
				<kml xmlns="http://earth.google.com/kml/2.0">
					<Document>
						<Style id="point">
							<IconStyle>
								<scale>1</scale>
								<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
								<Icon>
									<href>http://maps.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png</href>
								</Icon>
							</IconStyle>
						</Style>
						<Style id="polygon">
							<PolyStyle>
								<color>50F00014</color>
								<outline>1</outline>
							</PolyStyle>
						</Style>

						<!-- apply-templates only on those RDF objects that have coordinates -->
						<xsl:apply-templates select="//*[geo:lat and geo:long]" mode="rdf"/>
					</Document>
				</kml>
			</xsl:when>
			<xsl:when test="namespace-uri() = 'http://www.w3.org/2005/sparql-results#'">
				<kml xmlns="http://earth.google.com/kml/2.0">
					<Document>
						<Style id="point">
							<IconStyle>
								<scale>1</scale>
								<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>
								<Icon>
									<href>http://maps.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png</href>
								</Icon>
							</IconStyle>
						</Style>
						<Style id="polygon">
							<PolyStyle>
								<color>50F00014</color>
								<outline>1</outline>
							</PolyStyle>
						</Style>


						<!-- parse out the lat and long variables from the SPARQL query -->
						<xsl:variable name="latParam">
							<xsl:analyze-string select="$query" regex="geo:lat\s+\?([a-zA-Z0-9_]+)">
								<xsl:matching-substring>
									<xsl:value-of select="regex-group(1)"/>
								</xsl:matching-substring>
							</xsl:analyze-string>
						</xsl:variable>
						<xsl:variable name="longParam">
							<xsl:analyze-string select="$query" regex="geo:long\s+\?([a-zA-Z0-9_]+)">

								<xsl:matching-substring>
									<xsl:value-of select="regex-group(1)"/>
								</xsl:matching-substring>
							</xsl:analyze-string>
						</xsl:variable>

						<!-- if lat and long are available, then apply templates for results with coordinates -->
						<xsl:apply-templates select="descendant::res:result[res:binding[@name = $latParam] and res:binding[@name = $longParam]]">
							<xsl:with-param name="lat" select="$latParam"/>
							<xsl:with-param name="long" select="$longParam"/>
						</xsl:apply-templates>
					</Document>
				</kml>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- SELECT response -->
	<xsl:template match="res:result">
		<xsl:param name="lat"/>
		<xsl:param name="long"/>

		<xsl:variable name="label" select="res:binding[1]/res:*"/>

		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="$label"/>
			</name>
			<xsl:choose>
				<xsl:when test="string($lat) and string($long)">
					<styleUrl>#point</styleUrl>
				</xsl:when>
			</xsl:choose>
			<Point>
				<coordinates>
					<xsl:value-of select="concat(res:binding[@name = $long]/res:literal, ',', res:binding[@name = $lat]/res:literal)"/>
				</coordinates>
			</Point>
		</Placemark>
	</xsl:template>

	<!-- CONSTRUCT/DESCRIBE (process RDF) -->
	<xsl:template match="*" mode="rdf">
		<xsl:variable name="uri" select="@rdf:about"/>
		<xsl:variable name="object" as="element()*">
			<rdf:RDF>
				<xsl:choose>
					<xsl:when test="//*[nmo:hasFindspot/@rdf:resource=$uri]">
						<xsl:copy-of select="//*[nmo:hasFindspot/@rdf:resource=$uri]"/>
					</xsl:when>
					<xsl:when test="//*[nmo:hasFindspot/geo:SpatialThing[@rdf:about=$uri]]">
						<xsl:copy-of select="//*[nmo:hasFindspot/geo:SpatialThing[@rdf:about=$uri]]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="self::node()"/>
					</xsl:otherwise>
				</xsl:choose>
			</rdf:RDF>
		</xsl:variable>
		
		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<!-- get the name from the parent object -->
			<xsl:apply-templates select="$object/*" mode="name"/>			
			<xsl:choose>
				<xsl:when test="string(geo:lat) and string(geo:long)">
					<styleUrl>#point</styleUrl>
				</xsl:when>
			</xsl:choose>
			<Point>
				<coordinates>
					<xsl:value-of select="concat(geo:long, ',', geo:lat)"/>
				</coordinates>
			</Point>
		</Placemark>
	</xsl:template>
	
	<xsl:template match="*" mode="name">
		<name>
			<xsl:choose>
				<xsl:when test="dcterms:title">
					<xsl:value-of select="dcterms:title[1]"/>
				</xsl:when>
				<xsl:when test="skos:prefLabel">
					<xsl:choose>
						<xsl:when test="skos:prefLabel[@xml:lang = 'en']">
							<xsl:value-of select="skos:prefLabel[@xml:lang = 'en']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="skos:prefLabel[1]"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="foaf:name">
					<xsl:value-of select="foaf:name[1]"/>
				</xsl:when>
				<xsl:when test="rdfs:label">
					<xsl:value-of select="rdfs:label[1]"/>
				</xsl:when>
			</xsl:choose>
		</name>
	</xsl:template>
</xsl:stylesheet>
