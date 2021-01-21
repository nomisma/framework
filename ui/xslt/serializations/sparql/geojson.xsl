<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:nomisma="http://nomisma.org/"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>

	<xsl:param name="api" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
	<xsl:param name="findType" select="
			if ($api = 'getFindspots') then
				'find'
			else
				if ($api = 'getHoards') then
					'hoard'
				else
					''"/>

	<xsl:template match="/*[1]">
		<xsl:choose>
			<xsl:when test="/content/rdf:RDF/nmo:Region">
				<xsl:call-template name="region-features"/>
			</xsl:when>
			<xsl:when test="namespace-uri() = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'">
				<xsl:choose>
					<xsl:when test="$api = 'query.json'">
						<xsl:choose>
							<xsl:when test="count(//*[geo:lat and geo:long]) &gt; 0">
								<!-- apply-templates only on those RDF objects that have coordinates -->
								<xsl:text>{"type": "FeatureCollection","features": [</xsl:text>
								<xsl:apply-templates select="//*[geo:lat and geo:long]" mode="describe"/>
								<xsl:text>]}</xsl:text>
							</xsl:when>
							<xsl:otherwise>{}</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="geo:SpatialThing/osgeo:asGeoJSON">
								<xsl:apply-templates select="geo:SpatialThing" mode="poly">
									<xsl:with-param name="uri" select="*[1]/@rdf:about"/>
									<xsl:with-param name="label" select="*[1]/skos:prefLabel[@xml:lang = 'en']"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="geo:SpatialThing/geo:lat and geo:SpatialThing/geo:long">
								<xsl:apply-templates select="geo:SpatialThing" mode="point">
									<xsl:with-param name="uri" select="*[1]/@rdf:about"/>
									<xsl:with-param name="label" select="*[1]/skos:prefLabel[@xml:lang = 'en']"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>{}</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="namespace-uri() = 'http://www.w3.org/2005/sparql-results#'">
				<xsl:choose>
					<xsl:when test="count(descendant::res:result) &gt; 0">
						<!-- evaluate API and construct the attributes according to GeoJSON-T -->

						<xsl:choose>
							<xsl:when test="$api = 'getFindspots' or $api = 'getMints'">
								<xsl:text>{"type": "FeatureCollection","features": [</xsl:text>
								<xsl:apply-templates select="descendant::res:result"/>
								<xsl:text>]}</xsl:text>
							</xsl:when>
							<xsl:when test="$api = 'getHoards'">
								<xsl:variable name="coinType" select="doc('input:request')/request/parameters/parameter[name = 'coinType']/value"/>
								<xsl:variable name="id" select="tokenize($coinType, '/')[last()]"/>
								<!-- read timespans -->
								<xsl:variable name="fromDate" select="number(min(descendant::res:binding[@name = 'closingDate']/res:literal))"/>
								<xsl:variable name="toDate" select="number(max(descendant::res:binding[@name = 'closingDate']/res:literal))"/>
								<xsl:variable name="attributes"> "segmentType": "journey", "description": "Hoard distribution for a coin type", "uri":
										"<xsl:value-of select="$coinType"/>", "title": "<xsl:value-of select="$coinType"/>", "timespan": "[<xsl:value-of
										select="$fromDate"/>,,,<xsl:value-of select="$toDate"/>,]", "lp_id": "<xsl:value-of select="$id"/>" </xsl:variable>


								<xsl:text>{"type": "FeatureCollection","attributes":{</xsl:text>
								<xsl:value-of select="normalize-space($attributes)"/>
								<xsl:text>},"features": [</xsl:text>
								<xsl:apply-templates select="descendant::res:result"/>
								<xsl:text>]}</xsl:text>
							</xsl:when>
							<xsl:when test="$api = 'query.json'">
								<xsl:variable name="query" select="doc('input:request')/request/parameters/parameter[name = 'query']/value"/>

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

								<xsl:choose>
									<xsl:when test="string-length($latParam) &gt; 0 and string-length($longParam) &gt; 0">
										<xsl:text>{"type": "FeatureCollection","features": [</xsl:text>
										<xsl:apply-templates select="descendant::res:result[res:binding[@name = $latParam] and res:binding[@name = $longParam]]"
											mode="query">
											<xsl:with-param name="lat" select="$latParam"/>
											<xsl:with-param name="long" select="$longParam"/>
										</xsl:apply-templates>
										<xsl:text>]}</xsl:text>
									</xsl:when>
									<xsl:otherwise>{}</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>{}</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>{}</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- generate GeoJSON for id/ responses -->
	<xsl:template match="geo:SpatialThing" mode="point">
		<xsl:param name="uri"/>
		<xsl:param name="label"/>

		<xsl:text>{"type": "Feature","label":"</xsl:text>
		<xsl:value-of select="replace($label, '&#x022;', '\\&#x022;')"/>
		<xsl:text>","id":"</xsl:text>
		<xsl:value-of select="$uri"/>
		<xsl:text>","geometry": {"type": "Point","coordinates": [</xsl:text>
		<xsl:value-of select="geo:long"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="geo:lat"/>
		<xsl:text>]},"properties": {"toponym": "</xsl:text>
		<xsl:value-of select="$label"/>
		<xsl:text>","gazetteer_label": "</xsl:text>
		<xsl:value-of select="$label"/>
		<xsl:text>","type": "</xsl:text>
		<xsl:value-of select="lower-case(parent::node()/*[1]/local-name())"/>
		<xsl:text>"</xsl:text>
		<xsl:text>}}</xsl:text>
	</xsl:template>

	<xsl:template match="geo:SpatialThing" mode="poly">
		<xsl:param name="uri"/>
		<xsl:param name="label"/>

		<xsl:text>{"type": "Feature","label": "</xsl:text>
		<xsl:value-of select="replace($label, '&#x022;', '\\&#x022;')"/>
		<xsl:text>","id":"</xsl:text>
		<xsl:value-of select="$uri"/>
		<xsl:text>","geometry":</xsl:text>
		<xsl:value-of select="osgeo:asGeoJSON"/>
		<!-- properties -->
		<xsl:text>,"properties": {"toponym": "</xsl:text>
		<xsl:value-of select="$label"/>
		<xsl:text>","gazetteer_label": "</xsl:text>
		<xsl:value-of select="$label"/>
		<xsl:text>","type": "</xsl:text>
		<xsl:value-of select="lower-case(parent::node()/*[1]/local-name())"/>
		<xsl:text>"</xsl:text>
		<xsl:text>}}</xsl:text>
	</xsl:template>

	<!-- Combine region polygon and SPARQL mint results into same FeatureCollection -->
	<xsl:template name="region-features">
		<xsl:text>{"type": "FeatureCollection","features": [</xsl:text>
		<xsl:if test="descendant::geo:SpatialThing/osgeo:asGeoJSON">
			<xsl:apply-templates select="descendant::geo:SpatialThing" mode="poly">
				<xsl:with-param name="uri" select="rdf:RDF/*[1]/@rdf:about"/>
				<xsl:with-param name="label" select="rdf:RDF/*[1]/skos:prefLabel[@xml:lang = 'en']"/>
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="descendant::geo:SpatialThing/osgeo:asGeoJSON and descendant::res:result">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="descendant::res:result"/>

		<xsl:text>]}</xsl:text>
	</xsl:template>

	<!-- GeoJSON result for general SELECT SPARQL query lat/long -->
	<xsl:template match="res:result" mode="query">
		<xsl:param name="lat"/>
		<xsl:param name="long"/>

		<xsl:variable name="label" select="res:binding[1]/res:*"/>

		<xsl:text>{"type": "Feature","label":"</xsl:text>
		<xsl:value-of select="replace($label, '&#x022;', '\\&#x022;')"/>
		<xsl:text>"</xsl:text>
		<xsl:if test="matches($label, 'https?://')">
			<xsl:text>,"id":"</xsl:text>
			<xsl:value-of select="$label"/>
			<xsl:text>"</xsl:text>
		</xsl:if>
		<xsl:text>,</xsl:text>
		<!-- geometry -->
		<xsl:text>"geometry": {"type": "Point","coordinates": [</xsl:text>
		<xsl:value-of select="res:binding[@name = $long]/res:literal"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="res:binding[@name = $lat]/res:literal"/>
		<xsl:text>]}}</xsl:text>
		<xsl:if test="not(position() = last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- GeoJSON result for CONSTRUCT/DESCRIBE SPARQL query response -->
	<xsl:template match="*" mode="describe">
		<xsl:variable name="uri" select="@rdf:about"/>
		<xsl:variable name="object" as="element()*">
			<rdf:RDF>
				<xsl:choose>
					<xsl:when test="//*[nmo:hasFindspot/@rdf:resource = $uri]">
						<xsl:copy-of select="//*[nmo:hasFindspot/@rdf:resource = $uri]"/>
					</xsl:when>
					<xsl:when test="//*[nmo:hasFindspot/geo:SpatialThing[@rdf:about = $uri]]">
						<xsl:copy-of select="//*[nmo:hasFindspot/geo:SpatialThing[@rdf:about = $uri]]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="self::node()"/>
					</xsl:otherwise>
				</xsl:choose>
			</rdf:RDF>
		</xsl:variable>

		<xsl:variable name="label">
			<xsl:apply-templates select="$object/*" mode="name"/>
		</xsl:variable>

		<xsl:text>{"type": "Feature","label":"</xsl:text>
		<xsl:value-of select="replace($label, '&#x022;', '\\&#x022;')"/>
		<xsl:text>","id":"</xsl:text>
		<xsl:value-of select="$object/*[1]/@rdf:about"/>
		<xsl:text>",</xsl:text>
		<!-- geometry -->
		<xsl:text>"geometry": {"type": "Point","coordinates": [</xsl:text>
		<xsl:value-of select="geo:long"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="geo:lat"/>
		<xsl:text>]}}</xsl:text>
		<xsl:if test="not(position() = last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="name">
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
	</xsl:template>

	<!-- other GeoJSON API responses -->
	<xsl:template match="res:result">
		<xsl:choose>
			<xsl:when test="res:binding[@name = 'poly']">
				<xsl:text>{"type": "Feature","geometry":</xsl:text>
				<xsl:value-of select="res:binding[@name = 'poly']/res:literal"/>
				<xsl:text>,"label": ",</xsl:text>
				<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
				<xsl:text>", "properties": {"toponym": "</xsl:text>
				<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
				<xsl:text>", "gazetteer_label": "</xsl:text>
				<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
				<xsl:text>", "gazetteer_uri": "</xsl:text>
				<xsl:value-of select="res:binding[@name = 'place']/res:uri"/>
				<xsl:text>","type": "</xsl:text>
				<xsl:value-of select="
						if ($api = 'getMints') then
							'region'
						else
							$findType"/>
				<xsl:text>"</xsl:text>
				<xsl:text>}}</xsl:text>
				<xsl:if test="not(position() = last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{"type": "Feature","label":"</xsl:text>
				<xsl:value-of
					select="
						if (res:binding[@name = 'hoardLabel']/res:literal) then
							res:binding[@name = 'hoardLabel']/res:literal
						else
							res:binding[@name = 'label']/res:literal"/>
				<xsl:text>",</xsl:text>
				<xsl:if test="res:binding[@name = 'hoard']/res:uri">
					<xsl:text>"id":"</xsl:text>
					<xsl:value-of select="res:binding[@name = 'hoard']/res:uri"/>
					<xsl:text>",</xsl:text>
				</xsl:if>
				<!-- geometry -->
				<xsl:text>"geometry": {"type": "Point","coordinates": [</xsl:text>
				<xsl:value-of select="res:binding[@name = 'long']/res:literal"/>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="res:binding[@name = 'lat']/res:literal"/>
				<xsl:text>]},</xsl:text>
				<!-- when -->
				<xsl:if test="res:binding[@name = 'closingDate']">
					<xsl:text>"when":{"timespans":[{</xsl:text>
					<xsl:text>"start":"</xsl:text>
					<xsl:value-of select="nomisma:xsdToIso(res:binding[@name = 'closingDate']/res:literal)"/>
					<xsl:text>","end":"</xsl:text>
					<xsl:value-of select="nomisma:xsdToIso(res:binding[@name = 'closingDate']/res:literal)"/>
					<xsl:text>"</xsl:text>
					<xsl:text>}]},</xsl:text>
				</xsl:if>
				<!-- properties -->
				<xsl:text>"properties": {"toponym": "</xsl:text>
				<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
				<xsl:text>","gazetteer_label": "</xsl:text>
				<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
				<xsl:text>", "gazetteer_uri": "</xsl:text>
				<xsl:value-of select="res:binding[@name = 'place']/res:uri"/>
				<xsl:text>","type": "</xsl:text>
				<xsl:value-of select="
						if ($api = 'getMints') then
							'mint'
						else
							$findType"/>
				<xsl:text>"</xsl:text>
				
				<xsl:if test="res:binding[@name = 'count']">
					<xsl:text>,"count":</xsl:text>
					<xsl:value-of select="res:binding[@name='count']/res:literal"/>
				</xsl:if>
				
				<xsl:if test="res:binding[@name = 'closingDate']">
					<xsl:text>,"closing_date":"</xsl:text>
					<xsl:value-of select="nomisma:normalizeDate(res:binding[@name='closingDate']/res:literal)"/>
					<xsl:text>"</xsl:text>
				</xsl:if>
				<xsl:text></xsl:text>
				<xsl:text>}}</xsl:text>
				<xsl:if test="not(position() = last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
