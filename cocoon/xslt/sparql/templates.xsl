<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	exclude-result-prefixes="xs res" version="2.0">
	<xsl:param name="identifiers"/>
	<xsl:param name="constraints"/>
	<xsl:param name="template"/>
	<xsl:param name="uri"/>
	<xsl:param name="curie"/>
	<xsl:param name="endpoint"/>
	<xsl:param name="geonames_api_key"/>

	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>


	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$template = 'display'">
				<xsl:call-template name="display"/>
			</xsl:when>
			<xsl:when test="$template = 'kml'">
				<xsl:call-template name="kml"/>
			</xsl:when>
			<xsl:when test="$template = 'closingDate'">
				<xsl:call-template name="closingDate"/>
			</xsl:when>
			<xsl:when test="$template = 'avgWeight'">
				<xsl:call-template name="avgWeight"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="display">
		<xsl:variable name="query">
			<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			
			SELECT ?object ?title ?publisher ?identifier ?collection ?weight ?axis ?diameter ?obvThumb ?revThumb ?obvRef ?revRef  WHERE {
			?object nm:type_series_item <typeUri>.
			?object nm:numismatic_term <http://nomisma.org/id/coin>.
			?object dcterms:title ?title .
			?object dcterms:publisher ?publisher .
			OPTIONAL { ?object dcterms:identifier ?identifier } .
			OPTIONAL { ?object nm:collection ?collection } .
			OPTIONAL { ?object nm:weight ?weight }
			OPTIONAL { ?object nm:axis ?axis }
			OPTIONAL { ?object nm:diameter ?diameter }
			OPTIONAL { ?object nm:obverseThumbnail ?obvThumb }
			OPTIONAL { ?object nm:reverseThumbnail ?revThumb }
			OPTIONAL { ?object nm:obverseReference ?obvRef }
			OPTIONAL { ?object nm:reverseReference ?revRef }}
			ORDER BY ASC(?publisher)]]>
		</xsl:variable>
		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
		<xsl:apply-templates select="document($service)/res:sparql" mode="display"/>
	</xsl:template>

	<xsl:template name="kml">
		<xsl:variable name="query">
			<xsl:choose>
				<xsl:when test="$curie='mint'">
					<![CDATA[
					PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX dcterms:  <http://purl.org/dc/terms/>
					PREFIX nm:       <http://nomisma.org/id/>
					PREFIX owl:      <http://www.w3.org/2002/07/owl#>
					PREFIX gml: <http://www.opengis.net/gml/>
					SELECT DISTINCT ?findspot ?gml ?object ?title WHERE {
					{?type nm:mint <URI> .
					?object nm:type_series_item ?type.
					?object nm:findspot ?findspot
					} UNION {
					?object nm:mint <URI> .
					?object nm:findspot ?findspot
					OPTIONAL {?findspot gml:pos ?gml }
					}
					OPTIONAL {?object dcterms:title ?title}
					}]]>
				</xsl:when>
				<xsl:when test="$curie='type_series_item'">
					<![CDATA[
					PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX dcterms:  <http://purl.org/dc/terms/>
					PREFIX nm:       <http://nomisma.org/id/>
					PREFIX owl:      <http://www.w3.org/2002/07/owl#>
					PREFIX gml: <http://www.opengis.net/gml/>
					SELECT ?object ?findspot ?gml ?title WHERE {
					?object nm:type_series_item <URI> .
					?object nm:findspot ?findspot
					OPTIONAL {?object dcterms:title ?title}
					OPTIONAL {?findspot gml:pos ?gml }
					}
					]]>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'URI', $uri))), '&amp;output=xml')"/>

		<xsl:apply-templates select="document($service)/res:sparql" mode="kml"/>
	</xsl:template>

	<xsl:template name="closingDate">
		<xsl:variable name="query">
			<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX owl:      <http://www.w3.org/2002/07/owl#>
			PREFIX xsd:	<http://www.w3.org/2001/XMLSchema#>
			SELECT (MAX(xsd:int(?date)) AS ?year)
			WHERE {
			<IDENTIFIERS>
			}
			]]>
		</xsl:variable>

		<xsl:variable name="replace">
			<xsl:for-each select="tokenize($identifiers, '\|')">
				<xsl:choose>
					<xsl:when test="position() = 1">
						<xsl:text>{&lt;</xsl:text>
						<xsl:value-of select="."/>
						<xsl:text>&gt; nm:end_date ?date }</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>UNION {&lt;</xsl:text>
						<xsl:value-of select="."/>
						<xsl:text>&gt; nm:end_date ?date }</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="service"
			select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, '&lt;IDENTIFIERS&gt;', $replace))), '&amp;output=xml')"/>

		<!-- no need to call template, create XML-RPC response here:-->

		<response>
			<xsl:value-of select="number(document($service)/descendant::res:binding[@name='year']/res:literal)"/>
		</response>
	</xsl:template>
	
	<xsl:template name="avgWeight">
		<xsl:variable name="query">
			<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:	<http://nomisma.org/id/>
			PREFIX xs:	<http://www.w3.org/2001/XMLSchema#>
			SELECT (AVG(xs:decimal(?weight)) AS ?average)
			WHERE {
			<CONSTRAINTS>
			}
			]]>
		</xsl:variable>
		
		<xsl:variable name="replace">
			<xsl:text>{</xsl:text>
			<xsl:for-each select="tokenize($constraints, ' AND ')">
				<xsl:text>?coin </xsl:text>
				<xsl:value-of select="."/>
				<xsl:text> .</xsl:text>
			</xsl:for-each>
			<xsl:text>?coin nm:weight ?weight</xsl:text>
			<xsl:text>} UNION {</xsl:text>
			<xsl:for-each select="tokenize($constraints, ' AND ')">
				<xsl:text>?type </xsl:text>
				<xsl:value-of select="."/>
				<xsl:text> .</xsl:text>
			</xsl:for-each>
			<xsl:text>?coin nm:type_series_item ?type .</xsl:text>
			<xsl:text>?coin nm:weight ?weight</xsl:text>			
			<xsl:text>}</xsl:text>
		</xsl:variable>
		
		<xsl:variable name="service"
			select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, '&lt;CONSTRAINTS&gt;', $replace))), '&amp;output=xml')"/>
		
		<response>
			<xsl:value-of select="number(document($service)/descendant::res:binding[@name='average']/res:literal)"/>
		</response>
	</xsl:template>
	
	<xsl:template name="quantifyTypology">
		<xsl:variable name="query">
			<![CDATA[
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
			SELECT ?val ?label WHERE {
			{<http://nomisma.org/id/rrc-385.4> nm:denomination ?val}
			UNION { <http://nomisma.org/id/rrc-409.2> nm:denomination ?val }
			OPTIONAL { ?val skos:prefLabel ?label
			FILTER(langMatches(lang(?label), "en"))}
			}
			]]>
		</xsl:variable>
		
		<xsl:variable name="service"
			select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, '&lt;CONSTRAINTS&gt;', $replace))), '&amp;output=xml')"/>
	</xsl:template>

	<!-- **************** PROCESS SPARQL RESPONSE ****************-->
	<xsl:template match="res:sparql" mode="display">
		<xsl:variable name="coin-count" select="count(descendant::res:result)"/>
		<xsl:if test="$coin-count &gt; 0">
			<div class="center">
				<h2>Examples of this type</h2>

				<!-- choose between between Metis (preferred) or internal links -->
				<xsl:apply-templates select="descendant::res:result" mode="display"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:result" mode="display">
		<div class="g_doc">
			<span class="result_link">
				<a href="{res:binding[@name='object']/res:uri}" target="_blank">
					<xsl:value-of select="res:binding[@name='title']/res:literal"/>
				</a>
			</span>
			<dl>
				<xsl:if test="res:binding[@name='collection']/res:literal">
					<div>
						<dt>Collection: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="res:binding[@name='collection']/res:literal"/>
						</dd>
					</div>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='axis']/res:literal)">
					<div>
						<dt>Axis: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="string(res:binding[@name='axis']/res:literal)"/>
						</dd>
					</div>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='diameter']/res:literal)">
					<div>
						<dt>Diameter: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="string(res:binding[@name='diameter']/res:literal)"/>
						</dd>
					</div>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='weight']/res:literal)">
					<div>
						<dt>Weight: </dt>
						<dd style="margin-left:125px;">
							<xsl:value-of select="string(res:binding[@name='weight']/res:literal)"/>
						</dd>
					</div>
				</xsl:if>
			</dl>
			<div class="gi_c">
				<xsl:choose>
					<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and string(res:binding[@name='obvThumb']/res:uri)">
						<a class="thumbImage" href="{res:binding[@name='obvRef']/res:uri}"
							title="Obverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
							<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
						</a>
					</xsl:when>
					<xsl:when test="not(string(res:binding[@name='obvRef']/res:uri)) and string(res:binding[@name='obvThumb']/res:uri)">
						<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
					</xsl:when>
					<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and not(string(res:binding[@name='obvThumb']/res:uri))">
						<a class="thumbImage" href="{res:binding[@name='obvRef']/res:uri}">
							<img class="gi" src="{res:binding[@name='obvRef']/res:uri}" style="max-width:120px"/>
						</a>
					</xsl:when>
				</xsl:choose>
				<!-- reverse-->
				<xsl:choose>
					<xsl:when test="string(res:binding[@name='revRef']/res:uri) and string(res:binding[@name='revThumb']/res:uri)">
						<a class="thumbImage" href="{res:binding[@name='revRef']/res:uri}"
							title="Reverse of {res:binding[@name='identifier']/res:literal}: {res:binding[@name='collection']/res:literal}">
							<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
						</a>
					</xsl:when>
					<xsl:when test="not(string(res:binding[@name='revRef']/res:uri)) and string(res:binding[@name='revThumb']/res:uri)">
						<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
					</xsl:when>
					<xsl:when test="string(res:binding[@name='revRef']/res:uri) and not(string(res:binding[@name='revThumb']/res:uri))">
						<a class="thumbImage" href="{res:binding[@name='revRef']/res:uri}">
							<img class="gi" src="{res:binding[@name='revRef']/res:uri}" style="max-width:120px"/>
						</a>
					</xsl:when>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="res:sparql" mode="kml">
		<xsl:apply-templates select="descendant::res:result" mode="kml"/>
	</xsl:template>

	<xsl:template match="res:result" mode="kml">
		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:choose>
					<xsl:when test="res:binding[@name='title']/res:literal">
						<xsl:value-of select="res:binding[@name='title']/res:literal"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="res:binding[@name='object']/res:uri"/>
					</xsl:otherwise>
				</xsl:choose>
			</name>
			<description>
				<xsl:value-of select="res:binding[@name='object']/res:uri"/>
			</description>
			<styleUrl>#mapped</styleUrl>
			<!-- add placemark -->
			<xsl:choose>
				<xsl:when test="res:binding[@name='findspot']/res:literal">
					<xsl:variable name="coordinates" select="tokenize(res:binding[@name='findspot']/res:literal, ' ')"/>
					<Point>
						<coordinates>
							<xsl:value-of select="concat($coordinates[2], ',', $coordinates[1])"/>
						</coordinates>
					</Point>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="contains(res:binding[@name='findspot']/res:uri, 'geonames.org')">
							<xsl:variable name="geonameId"
								select="substring-before(substring-after(child::res:binding[@name='findspot']/res:uri, 'geonames.org/'), '/')"/>
							<xsl:if test="number($geonameId)">
								<xsl:variable name="geonames_data" as="element()*">
									<xml>
										<xsl:copy-of
											select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"
										/>
									</xml>
								</xsl:variable>
								<xsl:variable name="coordinates" select="concat($geonames_data//lng, ',', $geonames_data//lat)"/>
								<Point>
									<coordinates>
										<xsl:value-of select="$coordinates"/>
									</coordinates>
								</Point>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="coordinates" select="tokenize(res:binding[@name='gml']/res:literal, ' ')"/>
							<Point>
								<coordinates>
									<xsl:value-of select="concat($coordinates[2], ',', $coordinates[1])"/>
								</coordinates>
							</Point>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</Placemark>
	</xsl:template>
</xsl:stylesheet>
