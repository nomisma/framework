<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>

	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="id" select="substring-after(/content/rdf:RDF/*[1]/@rdf:about, 'id/')"/>
	<xsl:variable name="html-uri" select="concat(/content/config/url, 'id/', $id, '.html')"/>
	<xsl:variable name="type" select="/content/rdf:RDF/*[1]/name()"/>
	<xsl:variable name="title" select="/content/rdf:RDF/*[1]/skos:prefLabel[@xml:lang='en']"/>

	<!-- flickr -->
	<xsl:variable name="flickr_api_key" select="/content/config/flickr_api_key"/>
	<!--<xsl:variable name="service" select="concat('http://api.flickr.com/services/rest/?api_key=', $flickr_api_key)"/>-->

	<!-- sparql -->
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_query"/>

	<!-- definition of namespaces for turning in solr type field URIs into abbreviations -->
	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="//rdf:RDF/namespace::*[not(name()='xml')]">
				<namespace prefix="{name()}" uri="{.}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>

	<xsl:variable name="classes" as="item()*">
		<classes>
			<class map="false" types="false">nmo:Collection</class>
			<class map="true" types="true" prop="nmo:hasDenomination">nmo:Denomination</class>
			<class map="true" types="true" prop="?prop">rdac:Family</class>
			<class map="true" types="false">nmo:Ethnic</class>
			<class map="false" types="false">nmo:FieldOfNumismatics</class>
			<class map="true" types="false">nmo:Hoard</class>
			<class map="true" types="true" prop="nmo:hasManufacture">nmo:Manufacture</class>
			<class map="true" types="true" prop="nmo:hasMaterial">nmo:Material</class>
			<class map="true" types="true" prop="nmo:hasMint">nmo:Mint</class>
			<class map="false" types="false">nmo:NumismaticTerm</class>
			<class map="true" types="false">nmo:ObjectType</class>
			<class map="true" types="true" prop="?prop">foaf:Group</class>
			<class map="true" types="true" prop="?prop">foaf:Organization</class>			
			<class map="true" types="true" prop="?prop">foaf:Person</class>
			<class>nmo:ReferenceWork</class>
			<class map="true" types="true" prop="nmo:hasRegion">nmo:Region</class>
			<class map="false" types="false">org:Role</class>
			<class map="false" types="false">nmo:TypeSeries</class>
			<class map="false" types="false">un:Uncertainty</class>
			<class map="false" types="false">nmo:CoinWear</class>
		</classes>
	</xsl:variable>

	<xsl:variable name="prefix">
		<xsl:for-each select="$namespaces/namespace">
			<xsl:value-of select="concat(@prefix, ': ', @uri)"/>
			<xsl:if test="not(position()=last())">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en" prefix="{$prefix}" itemscope="" itemtype="http://schema.org/{if (contains($type, 'foaf:')) then substring-after($type, 'foaf:') else if ($type='nmo:Mint' or $type='nmo:Region')
			then 'Place' else 'Thing'}">
			<head>
				<title id="{$id}">nomisma.org: <xsl:value-of select="$id"/></title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="http://code.jquery.com/jquery-2.1.4.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>

				<xsl:if test="$classes//class[text()=$type]/@map=true()">
					<link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.css"/>
					<script src="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/leaflet.ajax.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/heatmap.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/leaflet-heatmap.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/display_map_functions.js"/>
				</xsl:if>
				<link rel="stylesheet" href="{$display_path}ui//css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$display_path}ui//javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/display_functions.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>

				<!-- schema.org metadata -->
				<xsl:for-each select="descendant::skos:prefLabel">
					<meta itemprop="name" content="{.}" lang="{@xml:lang}"/>
				</xsl:for-each>
				<xsl:for-each select="descendant::skos:definition">
					<meta itemprop="description" content="{.}" lang="{@xml:lang}"/>
				</xsl:for-each>
				<meta itemprop="url" content="{concat(/content/config/url, 'id/', $id)}"/>
				<xsl:for-each select="descendant::skos:exactMatch|descendant::skos:closeMatch">
					<meta itemprop="sameAs" content="{@rdf:resource}"/>
				</xsl:for-each>
				<xsl:if test="$type='nmo:Mint' and descendant::geo:lat">
					<meta itemprop="latitude" content="{descendant::geo:lat}"/>
					<meta itemprop="longitude" content="{descendant::geo:long}"/>
				</xsl:if>
				<xsl:if test="descendant::geo:SpatialThing/dcterms:isPartOf">
					<meta itemprop="containedIn" content="{descendant::geo:SpatialThing/dcterms:isPartOf/@rdf:resource}"/>
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
				<div class="col-md-{if ($classes//class[text()=$type]/@map=true()) then '6' else '9'}">
					<xsl:apply-templates select="/content/rdf:RDF/*" mode="type"/>
				</div>
				<div class="col-md-{if ($classes//class[text()=$type]/@map=true()) then '6' else '3'}">
					<div>
						<h3>Export</h3>
						<ul class="list-inline">
							<li><strong>Linked Data</strong></li>
							<li>
								<a href="https://github.com/nomisma/data/blob/master/id/{$id}.rdf">GitHub File</a>
							</li>
							<li>
								<a href="{$id}.rdf">RDF/XML</a>
							</li>
							<li>
								<a href="{$id}.ttl">RDF/TTL</a>
							</li>
							<li>
								<a href="{$id}.jsonld">JSON-LD</a>
							</li>
							<!--<li>
								<a href="{$id}.pelagios.rdf">Pelagios RDF/XML</a>
								</li>-->
							
						</ul>
						<xsl:if test="$classes//class[text()=$type]/@map=true()">
							<ul class="list-inline">
								<li><strong>Geographic Data</strong></li>
								<li>
									<a href="{$id}.kml">KML</a>
								</li>
								<li>
									<a href="{$display_path}apis/getMints?id={$id}">geoJSON (mints)</a>
								</li>
								<li>
									<a href="{$display_path}apis/getHoards?id={$id}">geoJSON (hoards)</a>
								</li>
								<li>
									<a href="{$display_path}apis/getFindspots?id={$id}">geoJSON (finds)</a>
								</li>
							</ul>							
						</xsl:if>
					</div>
					<xsl:if test="$classes//class[text()=$type]/@map=true()">
						<!--<div id="mapcontainer"/>-->
						<div id="mapcontainer" class="map">
							<div id="info"/>
						</div>
						<div style="margin:10px 0">
							<table>
								<tbody>
									<tr>
										<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
										<td style="width:100px">Mints</td>
										<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
										<td style="width:100px">Hoards</td>
										<td style="background-color:#a1d490;border:2px solid black;width:50px;"/>
										<td style="width:100px">Finds</td>
									</tr>
								</tbody>
							</table>
						</div>
					</xsl:if>
				</div>
			</div>
			<!-- list of associated coin types and example coins -->
			<xsl:if test="$classes//class[text()=$type]/@types=true()">
				<div class="row">
					<div class="col-md-12">
						<xsl:call-template name="nomisma:listTypes"/>
					</div>
				</div>
			</xsl:if>

			<div class="hidden">
				<span id="type">
					<xsl:value-of select="$type"/>
				</span>
			</div>
		</div>

		<!-- variables retrieved from the config and used in javascript -->
		<div class="hidden">
			<span id="mapboxKey">
				<xsl:value-of select="/content/config/mapboxKey"/>
			</span>
		</div>
	</xsl:template>

	<xsl:template match="*" mode="type">
		<div typeof="{name()}" about="{@rdf:about}">
			<xsl:if test="contains(@rdf:about, '#')">
				<xsl:attribute name="id" select="substring-after(@rdf:about, '#')"/>
			</xsl:if>
			<xsl:element name="{if(position()=1) then 'h2' else 'h3'}">
				<a href="{@rdf:about}">
					<xsl:choose>
						<xsl:when test="contains(@rdf:about, '#')">
							<xsl:value-of select="concat('#', substring-after(@rdf:about, '#'))"/>
						</xsl:when>
						<xsl:when test="contains(@rdf:about, 'geonames.org')">
							<xsl:value-of select="@rdf:about"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$id"/>
						</xsl:otherwise>
					</xsl:choose>
				</a>
				<small>
					<xsl:text> (</xsl:text>
					<a href="{concat(namespace-uri(.), local-name())}">
						<xsl:value-of select="name()"/>
					</a>
					<xsl:text>)</xsl:text>
				</small>
			</xsl:element>
			<dl class="dl-horizontal">
				<xsl:if test="skos:prefLabel">
					<dt>
						<a href="{concat($namespaces//namespace[@prefix='skos']/@uri, 'prefLabel')}">skos:prefLabel</a>
					</dt>
					<dd>
						<xsl:apply-templates select="skos:prefLabel" mode="prefLabel">
							<xsl:sort select="@xml:lang"/>
						</xsl:apply-templates>
					</dd>
				</xsl:if>
				<xsl:apply-templates select="skos:definition" mode="list-item">
					<xsl:sort select="@xml:lang"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="*[not(name()='skos:prefLabel') and not(name()='skos:definition')][not(child::*)]" mode="list-item">
					<xsl:sort select="name()"/>
					<xsl:sort select="@rdf:resource"/>
				</xsl:apply-templates>
			</dl>
			<xsl:apply-templates select="*[(child::*)]" mode="suburi">
				<xsl:sort select="name()"/>
				<xsl:sort select="@rdf:resource"/>
			</xsl:apply-templates>
		</div>
	</xsl:template>

	<xsl:template match="skos:prefLabel" mode="prefLabel">
		<span property="{name()}" lang="{@xml:lang}">
			<xsl:value-of select="."/>
		</span>
		<xsl:if test="string(@xml:lang)">
			<span class="lang">
				<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
			</span>
		</xsl:if>
		<xsl:if test="not(position()=last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="list-item">
		<xsl:variable name="name" select="name()"/>
		<dt>
			<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}">
				<xsl:value-of select="name()"/>
			</a>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="string(.)">
					<xsl:choose>
						<xsl:when test="name()= 'osgeo:asGeoJSON' and string-length(.) &gt; 100">
							<div id="geoJSON-fragment">
								<xsl:value-of select="substring(., 1, 100)"/>
								<xsl:text>...</xsl:text>
								<a href="#" class="toggle-geoJSON">[more]</a>
							</div>
							<div id="geoJSON-full" style="display:none">
								<span property="{name()}" xml:lang="{@xml:lang}">
									<xsl:value-of select="."/>
								</span>
								<a href="#" class="toggle-geoJSON">[less]</a>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<span property="{name()}">
								<xsl:if test="@xml:lang">
									<xsl:attribute name="xml:lang" select="@xml:lang"/>
								</xsl:if>
								<xsl:if test="@rdf:datatype">
									<xsl:attribute name="datatype" select="@rdf:datatype"/>
								</xsl:if>

								<xsl:choose>
									<xsl:when test="contains(@rdf:datatype, '#gYear')">
										<xsl:value-of select="nomisma:normalizeDate(.)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</span>
							<xsl:if test="string(@xml:lang)">
								<span class="lang">
									<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
								</span>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="string(@rdf:resource)">
					<span>
						<a href="{@rdf:resource}" rel="{name()}" title="{@rdf:resource}">
							<xsl:choose>
								<xsl:when test="name()='rdf:type'">
									<xsl:variable name="uri" select="@rdf:resource"/>
									<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@rdf:resource"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</span>
				</xsl:when>
			</xsl:choose>
		</dd>
	</xsl:template>

	<xsl:template match="*" mode="suburi">
		<xsl:variable name="about" select="if(@rdf:about) then @rdf:about else rdf:Description/@rdf:about"/>

		<div rel="{name()}">
			<xsl:if test="string($about)">
				<xsl:attribute name="resource" select="$about"/>
			</xsl:if>
			<h3>
				<xsl:value-of select="name()"/>
				<xsl:if test="string($about)">
					<small>
						<xsl:text> (</xsl:text>
						<a href="{$about}">
							<xsl:value-of select="$about"/>
						</a>
						<xsl:text>)</xsl:text>
					</small>
				</xsl:if>
			</h3>
			<dl class="dl-horizontal">
				<xsl:apply-templates select="descendant::skos:prefLabel" mode="list-item">
					<xsl:sort select="@xml:lang"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="descendant::skos:definition" mode="list-item">
					<xsl:sort select="@xml:lang"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="descendant::*[not(name()='skos:prefLabel') and not(name()='skos:definition')][not(child::*)]" mode="list-item">
					<xsl:sort select="name()"/>
					<xsl:sort select="@rdf:resource"/>
				</xsl:apply-templates>
			</dl>
		</div>
	</xsl:template>

	<!-- ***** SPARQL TEMPLATES ***** -->
	<xsl:variable name="listTypes-query"><![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT * WHERE {
 ?type PROP nm:ID ;
   a nmo:TypeSeriesItem ;
   skos:prefLabel ?label FILTER(langMatches(lang(?label), "en")) .
   MINUS {?type dcterms:isReplacedBy ?replaced}
   ?type dcterms:source ?source . 
   	?source skos:prefLabel ?sourceLabel FILTER(langMatches(lang(?sourceLabel), "en"))
   OPTIONAL {?type nmo:hasStartDate ?startDate}
   OPTIONAL {?type nmo:hasEndDate ?endDate}
   OPTIONAL {?type nmo:hasMint ?mint . 
   	?mint skos:prefLabel ?mintLabel FILTER(langMatches(lang(?mintLabel), "en"))}
   OPTIONAL {?type nmo:hasDenomination ?den . 
   	?den skos:prefLabel ?denLabel FILTER(langMatches(lang(?denLabel), "en"))}
}]]></xsl:variable>

	<!-- list up to 10 associate types for a authority or issuer -->
	<xsl:template name="nomisma:listTypes">
		<xsl:variable name="prop" select="$classes//class[text()=$type]/@prop"/>

		<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(concat(replace(replace($listTypes-query, 'ID', $id), 'PROP', $prop), ' LIMIT 10')), '&amp;output=xml')"/>
		<xsl:if test="doc-available($service)">
			<xsl:apply-templates select="document($service)/res:sparql" mode="listTypes"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="res:sparql[count(descendant::res:result) &gt; 0]" mode="listTypes">
		<!-- aggregate ids and get URI space -->
		<xsl:variable name="frags" select="tokenize(descendant::res:result[1]/res:binding[@name='type']/res:uri, '/')"/>
		<xsl:variable name="uri_space">
			<xsl:for-each select="$frags">
				<xsl:if test="not(position() = last())">
					<xsl:value-of select="."/>
					<xsl:text>/</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="ids" select="replace(string-join(descendant::res:result/res:binding[@name='type']/res:uri, '|'), $uri_space, '')"/>
		<!-- use the Numishare Results API to display example coins -->
		<xsl:variable name="sparqlResult" as="element()*">
			<xsl:variable name="service" select="concat('http://localhost:8080/orbeon/nomisma/apis/numishareResults?identifiers=', encode-for-uri($ids), '&amp;baseUri=',
				encode-for-uri($uri_space))"/>
			<xsl:copy-of select="document($service)/response"/>
		</xsl:variable>
		<xsl:variable name="prop" select="$classes//class[text()=$type]/@prop"/>

		<!-- HTML output -->
		<h3>Associated Types <small>(max 10)</small></h3>
		<div style="margin-bottom:10px;">
			<a href="#" class="toggle-button btn btn-primary" id="toggle-listTypes"><span class="glyphicon glyphicon-plus"/> View SPARQL for full query</a>
			<a href="{$display_path}query?query={encode-for-uri(replace($listTypes-query, 'ID', $id))}&amp;output=csv" title="Download CSV" class="btn btn-primary" style="margin-left:10px">
				<span class="glyphicon glyphicon-download"/>Download CSV</a>
		</div>
		<div id="listTypes" style="display:none">
			<pre>
				<xsl:value-of select="replace(replace($listTypes-query, 'ID', $id), 'PROP', $prop)"/>
			</pre>
		</div>

		<table class="table table-striped">
			<thead>
				<tr>
					<th>Type</th>
					<th>Type Series</th>
					<xsl:if test="$type='foaf:Person' or $type='foaf:Organization' or $type='rdac:Family'">
						<th>Role</th>
					</xsl:if>
					<th style="width:280px">Example</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="descendant::res:result">
					<xsl:variable name="type_id" select="replace(res:binding[@name='type']/res:uri, $uri_space, '')"/>

					<tr>
						<td>
							<a href="{res:binding[@name='type']/res:uri}">
								<xsl:value-of select="res:binding[@name='label']/res:literal"/>
							</a>
							<dl class="dl-horizontal">
								<xsl:if test="res:binding[@name='mint']/res:uri">
									<dt>Mint</dt>
									<dd>
										<a href="{res:binding[@name='mint']/res:uri}">
											<xsl:value-of select="res:binding[@name='mintLabel']/res:literal"/>
										</a>
									</dd>
								</xsl:if>
								<xsl:if test="res:binding[@name='den']/res:uri">
									<dt>Denomination</dt>
									<dd>
										<a href="{res:binding[@name='den']/res:uri}">
											<xsl:value-of select="res:binding[@name='denLabel']/res:literal"/>
										</a>
									</dd>
								</xsl:if>
								<xsl:if test="res:binding[@name='startDate']/res:literal or res:binding[@name='endDate']/res:literal">
									<dt>Date</dt>
									<dd>
										<xsl:value-of select="nomisma:normalizeDate(res:binding[@name='startDate']/res:literal)"/>
										<xsl:if test="res:binding[@name='startDate']/res:literal and res:binding[@name='startDate']/res:literal"> - </xsl:if>
										<xsl:value-of select="nomisma:normalizeDate(res:binding[@name='endDate']/res:literal)"/>
									</dd>
								</xsl:if>
							</dl>
						</td>
						<td>
							<a href="{res:binding[@name='source']/res:uri}">
								<xsl:value-of select="res:binding[@name='sourceLabel']/res:literal"/>
							</a>
						</td>
						<xsl:if test="$type = 'foaf:Group' or $type='foaf:Person' or $type='foaf:Organization' or $type='rdac:Family'">
							<td>
								<xsl:variable name="uri" select="res:binding[@name='prop']/res:uri"/>
								<a href="{$uri}">
									<!--<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>-->
									<xsl:value-of select="$uri"/>
								</a>

							</td>
						</xsl:if>
						<td class="text-right">
							<xsl:apply-templates select="$sparqlResult//group[@id=$type_id]/descendant::object" mode="results"/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>


	<xsl:template match="object" mode="results">
		<xsl:variable name="position" select="position()"/>
		<!-- obverse -->
		<xsl:choose>
			<xsl:when test="string(obvRef) and string(obvThumb)">
				<a class="thumbImage" rel="gallery" href="{obvRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{obvThumb}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(obvRef)) and string(obvThumb)">
				<img src="{obvThumb}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(obvRef) and not(string(obvThumb))">
				<a class="thumbImage" rel="gallery" href="{obvRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{obvRef}" style="max-width:120px"/>
				</a>
			</xsl:when>
		</xsl:choose>
		<!-- reverse-->
		<xsl:choose>
			<xsl:when test="string(revRef) and string(revThumb)">
				<a class="thumbImage" rel="gallery" href="{revRef}" title="Reverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{revThumb}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(revRef)) and string(revThumb)">
				<img src="{revThumb}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(revRef) and not(string(revThumb))">
				<a class="thumbImage" rel="gallery" href="{revRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{revRef}" style="max-width:120px"/>
				</a>
			</xsl:when>
		</xsl:choose>
		<!-- combined -->
		<xsl:choose>
			<xsl:when test="string(comRef) and string(comThumb)">
				<a class="thumbImage" rel="gallery" href="{comRef}" title="Reverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{comThumb}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(comRef)) and string(comThumb)">
				<img src="{comThumb}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(comRef) and not(string(comThumb))">
				<a class="thumbImage" rel="gallery" href="{comRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{comRef}" style="max-width:240px"/>
				</a>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ***** FUNCTIONS ***** -->
	<xsl:function name="nomisma:normalizeDate">
		<xsl:param name="date"/>

		<xsl:choose>
			<xsl:when test="number($date) &lt; 0">
				<xsl:value-of select="abs(number($date)) + 1"/>
				<xsl:text> B.C.</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>A.D. </xsl:text>
				<xsl:value-of select="number($date)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
