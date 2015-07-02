<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" exclude-result-prefixes="#all"
	xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:kml="http://earth.google.com/kml/2.0" version="2.0">


	<xsl:variable name="id" select="substring-after(//rdf:RDF/*[1]/@rdf:about, 'id/')"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_query"/>

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

				<xsl:apply-templates select="nmo:Mint|nmo:Region|nmo:Hoard">
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

				<!-- if it's a mint, then call the SPARQL kml template -->
				<xsl:choose>
					<xsl:when test="child::nmo:Mint">
						<xsl:call-template name="kml">
							<xsl:with-param name="uri" select="nmo:Mint/@rdf:about"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="child::nmo:Region">
						<xsl:call-template name="kml">
							<xsl:with-param name="uri" select="nmo:Region/@rdf:about"/>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>
				
			</Document>
		</kml>
	</xsl:template>

	<xsl:template match="nmo:Hoard|nmo:Mint|nmo:Region">
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
							<xsl:when test="$type='nmo:Mint' or $type='nmo:Region'">
								<styleUrl>#mint</styleUrl>
							</xsl:when>
							<xsl:when test="$type='nmo:Hoard'">
								<styleUrl>#findspot</styleUrl>
							</xsl:when>
						</xsl:choose>
						<Point>
							<coordinates>
								<xsl:value-of select="concat($long, ',', $lat)"/>
							</coordinates>
						</Point>
					</xsl:when>
					<!-- temporarily suppress the polygon, conflicts with leaflet -->
					<!--<xsl:when test="string($polygon)">
						<styleUrl>#polygon</styleUrl>
						<Polygon>
							<outerBoundaryIs>
								<LinearRing>
									<tessellate>1</tessellate>
									<coordinates>
										<xsl:analyze-string regex="\[(\d[^\]]+)\]" select="$polygon">
											<xsl:matching-substring>
												<xsl:for-each select="regex-group(1)">
													<xsl:value-of select="normalize-space(tokenize(., ',')[1])"/>
													<xsl:text>, </xsl:text>
													<xsl:value-of select="normalize-space(tokenize(., ',')[2])"/>
													<xsl:text>, 0.00&#x000A;</xsl:text>
												</xsl:for-each>
											</xsl:matching-substring>
										</xsl:analyze-string>
									</coordinates>
								</LinearRing>
							</outerBoundaryIs>
						</Polygon>
					</xsl:when>-->
				</xsl:choose>
			</Placemark>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="kml">
		<xsl:param name="uri"/>
		
		<xsl:variable name="query">
			<![CDATA[PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dcterms:  <http://purl.org/dc/terms/>
PREFIX dcmitype:	<http://purl.org/dc/dcmitype/>
PREFIX nm:       <http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX rdfs:	<http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT DISTINCT ?findspot ?lat ?long ?name WHERE {
{ ?coinType nmo:hasMint <URI> ;
  a nmo:TypeSeriesItem . 
 ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  nmo:hasFindspot ?findspot }
UNION { ?coinType nmo:hasMint <URI> ;
  a nmo:TypeSeriesItem .
  ?object nmo:hasTypeSeriesItem ?coinType ;
  rdf:type nmo:NumismaticObject ;
  dcterms:isPartOf ?hoard .
  ?hoard nmo:hasFindspot ?findspot }
UNION { ?coinType nmo:hasMint <URI> ;
  a nmo:TypeSeriesItem .
?contents nmo:hasTypeSeriesItem ?coinType ;
                  a dcmitype:Collection .
  ?object dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?findspot }
 UNION { ?contents nmo:hasMint <URI> ;
                  a dcmitype:Collection .
  ?object dcterms:tableOfContents ?contents ;
    nmo:hasFindspot ?findspot }
?object a ?type .
?findspot geo:lat ?lat ; geo:long ?long .
OPTIONAL { ?findspot foaf:name ?name }
OPTIONAL { ?findspot rdfs:label ?name }
}]]>
		</xsl:variable>
		
		<xsl:if test="string($query)">
			<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'URI', $uri))), '&amp;output=xml')"/>
			
			<xsl:apply-templates select="document($service)//res:result" mode="kml"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="res:result" mode="kml">
		<xsl:variable name="label" select="if (string(res:binding[@name='name']/res:literal)) then res:binding[@name='name']/res:literal else res:binding[@name='findspot']/res:uri"/>
		
		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="$label"/>
			</name>
			<description>
				<xsl:variable name="description">
					<![CDATA[<a href="]]><xsl:value-of select="res:binding[@name='findspot']/res:uri"/><![CDATA[">]]><xsl:value-of
						select="res:binding[@name='findspot']/res:uri"/><![CDATA[</a>]]>
				</xsl:variable>
				<xsl:value-of select="normalize-space($description)"/>
			</description>
			<styleUrl>#findspot</styleUrl>
			<Point>
				<coordinates>
					<xsl:value-of select="concat(res:binding[@name='long']/res:literal, ',', res:binding[@name='lat']/res:literal)"/>
				</coordinates>
			</Point>
		</Placemark>
	</xsl:template>
</xsl:stylesheet>
