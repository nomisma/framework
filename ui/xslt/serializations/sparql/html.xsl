<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../rdf/html-templates.xsl"/>

	<xsl:param name="query" select="doc('input:request')/request/parameters/parameter[name = 'query']/value"/>
	<xsl:param name="lang">en</xsl:param>

	<xsl:variable name="display_path">./</xsl:variable>

	<xsl:variable name="namespaces" as="node()*">
		<xsl:copy-of select="//config/namespaces"/>
	</xsl:variable>

	<xsl:variable name="hasGeo" as="xs:boolean">
		<!-- evaluate response -->
		<xsl:choose>
			<!-- when the response is RDF, this is a CONSTRUCT or DESCRIBE query, so evaluate presense of coordinates in RDF -->
			<xsl:when test="/content/*[1]/namespace-uri() = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'">
				<xsl:choose>
					<xsl:when test="descendant::geo:lat and descendant::geo:long">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- otherwise evaluate on whether the query itself contains the geo properties -->
				<xsl:choose>
					<xsl:when test="contains($query, 'geo:lat') and contains($query, 'geo:long')">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: SPARQL Results</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<script type="text/javascript" src="https://code.jquery.com/jquery-latest.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/result_functions.js"/>
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
				<xsl:if test="$hasGeo = true()">
					<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
					<script type="text/javascript" src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
					<link rel="stylesheet" href="{$display_path}ui/css/MarkerCluster.css"/>
					<link rel="stylesheet" href="{$display_path}ui/css/MarkerCluster.Default.css"/>					
					<script type="text/javascript" src="{$display_path}ui/javascript/leaflet.markercluster.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/leaflet.ajax.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/sparql_map_functions.js"/>
				</xsl:if>

				<!-- google analytics -->
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid content">
			<div class="row">
				<div class="col-md-12">
					<xsl:choose>
						<xsl:when test="descendant::res:sparql">
							<xsl:apply-templates select="descendant::res:sparql"/>
						</xsl:when>
						<xsl:when test="descendant::rdf:RDF">
							<xsl:apply-templates select="descendant::rdf:RDF"/>
						</xsl:when>
					</xsl:choose>

					<!-- hidden variables -->
					<div class="hidden">
						<span id="mapboxKey">
							<xsl:value-of select="/content/config/mapboxKey"/>
						</span>
						<span id="query">
							<!--<xsl:value-of select="$query"/>-->
							<xsl:value-of select="encode-for-uri($query)"/>
						</span>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- SPARQL DESCRIBE/CONSTRUCT response -->
	<xsl:template match="rdf:RDF">
		<h1>Results</h1>

		<!-- display links to download -->
		<ul class="list-inline">
			<li>
				<strong>Download: </strong>
			</li>
			<li>
				<a href="./query?query={encode-for-uri($query)}&amp;output=xml">RDF/XML</a>
			</li>
			<li>
				<a href="./query?query={encode-for-uri($query)}&amp;output=text">Turtle</a>
			</li>
			<li>
				<a href="./query?query={encode-for-uri($query)}&amp;output=json">JSON-LD</a>
			</li>
			<xsl:if test="$hasGeo = true()">
				<li>
					<a href="./apis/query.json?query={encode-for-uri($query)}">GeoJSON</a>
				</li>
				<li>
					<a href="./apis/query.kml?query={encode-for-uri($query)}">KML</a>
				</li>
			</xsl:if>
		</ul>

		<!-- include map when applicable -->
		<xsl:if test="$hasGeo = true()">
			<div id="mapcontainer" class="map-normal"/>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="count(*) &gt; 0">
				<table class="table table-striped">
					<tbody>
						<xsl:for-each select="*">
							<tr>
								<td>
									<xsl:apply-templates select="." mode="type">
										<xsl:with-param name="mode">sparql</xsl:with-param>
									</xsl:apply-templates>
								</td>
							</tr>
						</xsl:for-each>

					</tbody>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<p>Your query did not yield results.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- SPARQL SELECT response -->
	<xsl:template match="res:sparql">
		<!-- evaluate the type of response to handle ASK and SELECT -->
		<xsl:choose>
			<xsl:when test="res:results">
				<h1>Results</h1>

				<!-- display links to download -->
				<ul class="list-inline">
					<li>
						<strong>Download: </strong>
					</li>
					<li>
						<a href="./query?query={encode-for-uri($query)}&amp;output=csv">CSV</a>
					</li>
					<xsl:if test="$hasGeo = true()">
						<li>
							<a href="./apis/query.json?query={encode-for-uri($query)}">GeoJSON</a>
						</li>
						<li>
							<a href="./apis/query.kml?query={encode-for-uri($query)}">KML</a>
						</li>
					</xsl:if>
				</ul>

				<!-- include map when applicable -->
				<xsl:if test="$hasGeo = true()">
					<div id="mapcontainer" class="map-normal"/>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="count(descendant::res:result) &gt; 0">
						<table class="table table-striped">
							<thead>
								<tr>
									<xsl:for-each select="res:head/res:variable">
										<th>
											<xsl:value-of select="@name"/>
										</th>
									</xsl:for-each>
								</tr>
							</thead>
							<tbody>
								<xsl:apply-templates select="descendant::res:result"/>
							</tbody>
						</table>
					</xsl:when>
					<xsl:otherwise>
						<p>Your query did not yield results.</p>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>
			<xsl:when test="res:boolean">
				<h1>Response</h1>
				<p> The response to your query is <strong><xsl:value-of select="res:boolean"/></strong>.</p>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:variable name="result" as="element()*">
			<xsl:copy-of select="."/>
		</xsl:variable>

		<tr>
			<xsl:for-each select="ancestor::res:sparql/res:head/res:variable">
				<xsl:variable name="name" select="@name"/>

				<xsl:choose>
					<xsl:when test="$result/res:binding[@name = $name]">
						<xsl:apply-templates select="$result/res:binding[@name = $name]"/>
					</xsl:when>
					<xsl:otherwise>
						<td/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:for-each>

		</tr>
	</xsl:template>

	<xsl:template match="res:binding">
		<td>
			<xsl:choose>
				<xsl:when test="res:uri">
					<xsl:variable name="uri" select="res:uri"/>
					<a href="{res:uri}">
						<xsl:choose>
							<xsl:when test="$namespaces//namespace[contains($uri, @uri)]">
								<xsl:value-of
									select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$uri"/>
							</xsl:otherwise>
						</xsl:choose>
					</a>
				</xsl:when>
				<xsl:when test="res:bnode">
					<xsl:text>_:</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="res:literal"/>
					<xsl:if test="res:literal/@xml:lang">
						<i> (<xsl:value-of select="res:literal/@xml:lang"/>)</i>
					</xsl:if>
					<xsl:if test="res:literal/@datatype">
						<xsl:variable name="datatype" select="res:literal/@datatype"/>
						<xsl:variable name="uri"
							select="
								if (contains($datatype, 'xs:')) then
									replace($datatype, 'xs:', 'http://www.w3.org/2001/XMLSchema#')
								else
									if (contains($datatype, 'xsd:')) then
										replace($datatype, 'xsd:', 'http://www.w3.org/2001/XMLSchema#')
									else
										$datatype"/>

						<i> (<a href="{$uri}">
								<xsl:value-of
									select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
								/></a>)</i>

					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

</xsl:stylesheet>
