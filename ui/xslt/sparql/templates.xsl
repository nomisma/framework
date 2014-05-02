<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:nm="http://nomisma.org/id/" exclude-result-prefixes="xs res nm" version="2.0">
	<!-- config variables -->
	<xsl:variable name="sparql_endpoint" select="/config/sparql"/>
	<!-- url params -->
	<xsl:param name="identifiers" select="doc('input:request')/request/parameters/parameter[name='identifiers']/value"/>
	<xsl:param name="constraints" select="doc('input:request')/request/parameters/parameter[name='constraints']/value"/>
	<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='uri']/value"/>
	<xsl:param name="curie" select="doc('input:request')/request/parameters/parameter[name='curie']/value"/>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>	
	<xsl:param name="format" select="doc('input:request')/request/parameters/parameter[name='format']/value"/>

	<xsl:template name="display">
		<xsl:variable name="query">
			<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
			
			SELECT ?object ?title ?identifier ?collection ?weight ?axis ?diameter ?obvThumb ?revThumb ?obvRef ?revRef  WHERE {
			?object nm:type_series_item <typeUri>.
			?object a nm:coin .
			?object dcterms:title ?title .
			OPTIONAL { ?object dcterms:identifier ?identifier } .
			OPTIONAL { ?object nm:collection ?colUri .
			?colUri skos:prefLabel ?collection 
			FILTER(langMatches(lang(?collection), "EN"))}
			OPTIONAL { ?object nm:weight ?weight }
			OPTIONAL { ?object nm:axis ?axis }
			OPTIONAL { ?object nm:diameter ?diameter }
			OPTIONAL { ?object nm:obverseThumbnail ?obvThumb }
			OPTIONAL { ?object nm:reverseThumbnail ?revThumb }
			OPTIONAL { ?object nm:obverseReference ?obvRef }
			OPTIONAL { ?object nm:reverseReference ?revRef }}
			ORDER BY ASC(?collection)]]>
		</xsl:variable>
		<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
		<xsl:apply-templates select="document($service)/res:sparql" mode="display"/>
	</xsl:template>

	<xsl:template name="kml">
		<xsl:variable name="query">
			<xsl:choose>
				<xsl:when test="$curie='nm:mint'">
					<![CDATA[
					PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX dcterms:  <http://purl.org/dc/terms/>
					PREFIX nm:       <http://nomisma.org/id/>
					PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
					PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
					SELECT DISTINCT ?object ?findspot ?lat ?long ?title ?prefLabel ?closing_date WHERE {
					{?type nm:mint <URI> .
					?object nm:type_series_item ?type.
					?object nm:findspot ?findspot .
					?findspot geo:lat ?lat .
					?findspot geo:long ?long
					}
					UNION {
					?object nm:mint <URI> .
					?object nm:findspot ?findspot .
					?findspot geo:lat ?lat .
					?findspot geo:long ?long
					}					
					OPTIONAL {?object skos:prefLabel ?prefLabel}
					OPTIONAL {?object dcterms:title ?title}
					OPTIONAL {?object nm:closing_date ?closing_date}
					}]]>
				</xsl:when>
				<xsl:when test="$curie='nm:type_series_item'">
					<![CDATA[
					PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX dcterms:  <http://purl.org/dc/terms/>
					PREFIX nm:       <http://nomisma.org/id/>
					PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>
					PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
					SELECT ?object ?findspot ?lat ?long ?title ?prefLabel WHERE {
					?object nm:type_series_item <URI> .
					?object nm:findspot ?findspot .
					?findspot geo:lat ?lat .
					?findspot geo:long ?long .
					OPTIONAL {?object skos:prefLabel ?prefLabel}
					OPTIONAL {?object dcterms:title ?title}
					}
					]]>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string($query)">
			<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'URI', $uri))), '&amp;output=xml')"/>
			
			<kml xmlns="http://earth.google.com/kml/2.0">
				<Document>
					<xsl:apply-templates select="document($service)/res:sparql" mode="kml"/>
				</Document>
			</kml>
		</xsl:if>
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
			select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, '&lt;IDENTIFIERS&gt;', $replace))), '&amp;output=xml')"/>

		<!-- no need to call template, create XML-RPC response here:-->

		<xsl:choose>
			<xsl:when test="$format='json'">
				<xsl:text>{"closing_date":</xsl:text>
				<xsl:value-of select="number(document($service)/descendant::res:binding[@name='year']/res:literal)"/>
				<xsl:text>}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<response>
					<xsl:value-of select="number(document($service)/descendant::res:binding[@name='year']/res:literal)"/>
				</response>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="avgMeasurement">
		<xsl:param name="measurement"/>
		<xsl:variable name="query">
			<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:	<http://nomisma.org/id/>
			PREFIX xs:	<http://www.w3.org/2001/XMLSchema#>
			SELECT (AVG(xs:decimal(?MEASUREMENT)) AS ?average)
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
			<xsl:text>?coin nm:MEASUREMENT ?MEASUREMENT</xsl:text>
			<xsl:text>} UNION {</xsl:text>
			<xsl:for-each select="tokenize($constraints, ' AND ')">
				<!-- ignore collection -->
				<xsl:if test="not(contains(., 'nm:collection'))">
					<xsl:text>?type </xsl:text>
					<xsl:value-of select="."/>
					<xsl:text> .</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>?coin nm:type_series_item ?type .</xsl:text>
			<xsl:if test="contains($constraints, 'nm:collection')">
				<xsl:analyze-string select="$constraints" regex="(nm:collection\s&lt;[^&gt;]+&gt;)">
					<xsl:matching-substring>
						<xsl:value-of select="concat('?coin ', regex-group(1), '.')"/>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:if>
			<xsl:text>?coin nm:MEASUREMENT ?MEASUREMENT</xsl:text>
			<xsl:text>}</xsl:text>
		</xsl:variable>

		<xsl:variable name="service"
			select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace(replace($query, '&lt;CONSTRAINTS&gt;', replace($replace, '\\\\and', '&amp;&amp;')), 'MEASUREMENT', $measurement))), '&amp;output=xml')"/>

		<xsl:choose>
			<xsl:when test="$format='json'">
				<xsl:text>{"</xsl:text>
				<xsl:value-of select="$measurement"/>
				<xsl:text>":</xsl:text>
				<xsl:value-of select="number(document($service)/descendant::res:binding[@name='average']/res:literal)"/>
				<xsl:text>}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<response>
					<xsl:value-of select="number(document($service)/descendant::res:binding[@name='average']/res:literal)"/>
				</response>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getLabel">
		<xsl:variable name="query">
			<![CDATA[
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX skos:      <http://www.w3.org/2004/02/skos/core#>						
			SELECT DISTINCT ?label WHERE {
			<URI> skos:prefLabel ?label
			FILTER(langMatches(lang(?label), "LANG"))} 
			ORDER BY asc(?label)
			]]>
		</xsl:variable>
		<xsl:variable name="langStr" select="if (string($lang)) then $lang else 'en'"/>
		<xsl:variable name="service"
			select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace(replace($query, 'LANG', $langStr), 'URI', $uri))), '&amp;output=xml')"/>
		<xsl:choose>
			<xsl:when test="$format='json'">
				<xsl:text>{"label":"</xsl:text>
				<xsl:value-of select="document($service)/descendant::res:binding[@name='label']/res:literal"/>
				<xsl:text>"}</xsl:text>
			</xsl:when>
			<xsl:when test="$format='jsonp'">
				<xsl:text>jsonCallback ({"label":"</xsl:text>
				<xsl:value-of select="document($service)/descendant::res:binding[@name='label']/res:literal"/>
				<xsl:text>"})</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<response>
					<xsl:value-of select="document($service)/descendant::res:binding[@name='label']/res:literal"/>
				</response>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--<xsl:template name="quantifyTypology">
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
			select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, '&lt;CONSTRAINTS&gt;', $replace))), '&amp;output=xml')"/>
	</xsl:template>-->

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
		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="res:binding[@name='title']/res:literal">
					<xsl:value-of select="res:binding[@name='title']/res:literal"/>
				</xsl:when>
				<xsl:when test="res:binding[@name='prefLabel']/res:literal">
					<xsl:value-of select="res:binding[@name='prefLabel']/res:literal"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="res:binding[@name='object']/res:uri"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="$label"/>
			</name>
			<description>
				<![CDATA[
				<dl class="dl-horizontal"><dt>URI</dt><dd><a href="]]><xsl:value-of select="res:binding[@name='object']/res:uri"/><![CDATA[">]]><xsl:value-of
					select="res:binding[@name='object']/res:uri"/><![CDATA[</a></dd>]]>
				<xsl:if test="string(res:binding[@name='closing_date']/res:literal)">
					<![CDATA[<dt>Closing Date</dt><dd>]]><xsl:value-of select="nm:normalizeYear(res:binding[@name='closing_date']/res:literal)"
					/><![CDATA[</dd>]]>
				</xsl:if>
				<![CDATA[</dl>]]>
			</description>
			<styleUrl>#mapped</styleUrl>
			<Point>
				<coordinates>
					<xsl:value-of select="concat(res:binding[@name='long']/res:literal, ',', res:binding[@name='lat']/res:literal)"/>
				</coordinates>
			</Point>
		</Placemark>
	</xsl:template>

	<xsl:function name="nm:normalizeYear">
		<xsl:param name="gYear"/>
		
		<xsl:choose>
			<xsl:when test="number($gYear) &gt; 0">
				<xsl:if test="number($gYear) &lt; 400">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="number($gYear)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="abs(number($gYear)) + 1"/>
				<xsl:text> B.C.</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>
