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

	<xsl:variable name="prefix">
		<xsl:for-each select="$namespaces/namespace">
			<xsl:value-of select="concat(@prefix, ': ', @uri)"/>
			<xsl:if test="not(position()=last())">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en" prefix="{$prefix}">
			<head>
				<title id="{$id}">nomisma.org: <xsl:value-of select="$id"/></title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>

				<xsl:if test="$type='nmo:Mint' or $type='nmo:Hoard' or $type='nmo:Region'">
					<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
					<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.9&amp;sensor=false"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/display_map_functions.js"/>
				</xsl:if>
				<script type="text/javascript" src="{$display_path}ui/javascript/display_functions.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
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
				<div class="col-md-{if ($type='nmo:Mint' or $type='nmo:Hoard' or $type='nmo:Region') then '6' else '9'}">
					<xsl:apply-templates select="/content/rdf:RDF/*" mode="type"/>

					<!-- further context -->
					<xsl:if test="descendant::org:role/@rdf:resource">
						<xsl:call-template name="nomisma:listTypes"/>
					</xsl:if>
				</div>
				<div class="col-md-{if ($type='nmo:Mint' or $type='nmo:Hoard' or $type='nmo:Region') then '6' else '3'}">
					<div>
						<h3>Export</h3>
						<ul class="list-inline">
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
							<xsl:if test="$type='nmo:Mint' or $type='nmo:Hoard' or $type='nmo:Region'">
								<li>
									<a href="{$id}.kml">KML</a>
								</li>
							</xsl:if>
						</ul>
					</div>
					<xsl:if test="$type='nmo:Mint' or $type='nmo:Hoard' or $type='nmo:Region'">
						<div id="mapcontainer"/>
					</xsl:if>

					<!--<xsl:if test="$type != 'numismatic_term'">
						<xsl:variable name="predicate" select="if ($type='roman_emperor') then 'authority' else $type"/>
						<xsl:variable name="photos" as="element()*">
							<xsl:copy-of
								select="document(concat($service, '&amp;method=flickr.photos.search&amp;per_page=12&amp;machine_tags=nomisma:', $predicate, '=', $id))/*"
							/>
						</xsl:variable>
						<xsl:if test="count($photos//photo) &gt; 0">
							<div>
								<h3>Flickr Images of this Typology <small><a href="http://www.flickr.com/photos/tags/nomisma:{$predicate}={$id}">See all
											photos.</a></small></h3>
								<xsl:for-each select="$photos//photo">
									<div class="flickr_thumbnail">
										<a href="http://www.flickr.com/photos/{@owner}/{@id}" title="{@title}">
											<img
												src="{document(concat($service, '&amp;method=flickr.photos.getSizes&amp;photo_id=', @id))//size[@label='Thumbnail']/@source}"
												alt="{@title}"/>
										</a>
									</div>
								</xsl:for-each>
							</div>
						</xsl:if>
					</xsl:if>-->
				</div>
			</div>
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
		<span property="{name()}" xml:lang="{@xml:lang}">
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

SELECT * WHERE {
 ?type ?role nm:ID ;
   a nmo:TypeSeriesItem ;
   skos:prefLabel ?label
   OPTIONAL {?type nmo:hasStartDate ?startDate}
   OPTIONAL {?type nmo:hasEndDate ?endDate}
   FILTER(langMatches(lang(?label), "en"))
} ORDER BY ?label LIMIT 10]]></xsl:variable>

	<!-- list up to 10 associate types for a authority or issuer -->
	<xsl:template name="nomisma:listTypes">
		<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($listTypes-query, 'ID', $id)), '&amp;output=xml')"/>
		<xsl:if test="doc-available($service)">
			<xsl:apply-templates select="document($service)/res:sparql" mode="listTypes"/>
		</xsl:if>		
	</xsl:template>
	
	<xsl:template match="res:sparql[count(descendant::res:result) &gt; 0]" mode="listTypes">
		<h3>Associated Types <small>(max 10)</small></h3>
		<a href="#" class="toggle-button" id="toggle-listTypes"><span class="glyphicon glyphicon-plus"/> View SPARQL for full query</a>
		<div id="listTypes" style="display:none">
			<pre>
				<xsl:value-of select="replace(replace($listTypes-query, 'ID', $id), ' LIMIT 10', '')"/>
			</pre>
		</div>
		<table class="table table-striped">
			<thead>
				<tr>
					<th>Type</th>
					<th>From Date</th>
					<th>To Date</th>
					<th>Role</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="descendant::res:result">
					<tr>
						<td>
							<a href="{res:binding[@name='type']/res:uri}">
								<xsl:value-of select="res:binding[@name='label']/res:literal"/>
							</a>
						</td>
						<td>
							<xsl:value-of select="nomisma:normalizeDate(res:binding[@name='startDate']/res:literal)"/>
						</td>
						<td>
							<xsl:value-of select="nomisma:normalizeDate(res:binding[@name='endDate']/res:literal)"/>
						</td>
						<td>
							<xsl:variable name="uri" select="res:binding[@name='role']/res:uri"/>
							<a href="{$uri}">
								<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>
							</a>
							
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
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
