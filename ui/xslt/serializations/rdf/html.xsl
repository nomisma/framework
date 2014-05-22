<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>

	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="id" select="substring-after(/content/rdf:RDF/*[not(name()='geo:spatialThing')]/@rdf:about, 'id/')"/>
	<xsl:variable name="uri" select="concat('http://nomisma.org/id/', $id)"/>
	<xsl:variable name="html-uri" select="concat(/content/config/url, 'id/', $id)"/>
	<xsl:variable name="type" select="/content/rdf:RDF/*[not(name()='geo:spatialThing')]/name()"/>

	<!-- flickr -->
	<xsl:variable name="flickr_api_key" select="/content/config/flickr_api_key"/>
	<xsl:variable name="service" select="concat('http://api.flickr.com/services/rest/?api_key=', $flickr_api_key)"/>

	<!-- definition of namespaces for turning in solr type field URIs into abbreviations -->
	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<namespace prefix="ecrm" uri="http://erlangen-crm.org/current/"/>
			<namespace prefix="dcterms" uri="http://purl.org/dc/terms/"/>
			<namespace prefix="foaf" uri="http://xmlns.com/foaf/0.1/"/>
			<namespace prefix="geo" uri="http://www.w3.org/2003/01/geo/wgs84_pos#"/>
			<namespace prefix="nm" uri="http://nomisma.org/id/"/>
			<namespace prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>
			<namespace prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
			<namespace prefix="xsd" uri="http://www.w3.org/2001/XMLSchema#"/>
		</namespaces>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en"
			prefix="dcterms: http://purl.org/dc/terms/
			foaf: http://xmlns.com/foaf/0.1/
			geo:  http://www.w3.org/2003/01/geo/wgs84_pos#
			owl:  http://www.w3.org/2002/07/owl#
			rdfs: http://www.w3.org/2000/01/rdf-schema#
			rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
			skos: http://www.w3.org/2004/02/skos/core#
			ecrm: http://erlangen-crm.org/current/
			nm: http://nomisma.org/id/"
			vocab="http://nomisma.org/id/">
			<head>
				<title id="{$id}">nomisma.org: <xsl:value-of select="$id"/></title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>

				<xsl:if test="$type='nm:mint' or $type='nm:type_series_item' or $type='nm:hoard'">
					<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
					<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.9&amp;sensor=false"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/display_map_functions.js"/>
				</xsl:if>
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
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-9">
					<xsl:apply-templates select="/content/rdf:RDF/*" mode="type"/>
					<xsl:if test="$type='nm:mint' or $type='nm:type_series_item' or $type='nm:hoard'">
						<div id="mapcontainer"/>
					</xsl:if>
				</div>

				<div class="col-md-3">
					<div>
						<h3>Export</h3>
						<ul>
							<li>
								<a href="https://github.com/AmericanNumismaticSociety/nomisma-ids/blob/master/id/{$id}.txt">GitHub File</a>
							</li>
							<li>
								<a href="{$id}.rdf">RDF/XML</a>
							</li>
							<li>
								<a href="{$id}.ttl">RDF/TTL</a>
							</li>
							<li>
								<a href="http://www.w3.org/2012/pyRdfa/extract?uri={$html-uri}&amp;format=json">JSON-LD</a>
							</li>
							<li>
								<a href="{$id}.pelagios.rdf">Pelagios RDF/XML</a>
							</li>
							<!--<xsl:if test="$type='nm:type_series_item'">
								<li>
									<a href="{$id}.nuds">NUDS/XML</a>
								</li>
							</xsl:if>-->
							<xsl:if test="$type='nm:mint' or $type='nm:type_series_item' or $type='nm:hoard'">
								<li>
									<a href="{$id}.kml">KML</a>
								</li>
							</xsl:if>
							<li>
								<a href="http://isaw2.atlantides.org/lawdi/force-graph.html?s={$uri}">Visualize RDF</a>
							</li>
						</ul>
					</div>
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
			<xsl:if test="contains(@rdf:resource, '#this')">
				<a name="#this"/>
			</xsl:if>
			<h2>
				<a href="{@rdf:about}">
					<xsl:choose>
						<xsl:when test="contains(@rdf:about, '#this')">#this</xsl:when>
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
			</h2>
			<dl class="dl-horizontal">
				<xsl:apply-templates select="skos:prefLabel" mode="list-item">
					<xsl:sort select="@xml:lang"/>
				</xsl:apply-templates>
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
					<span property="{name()}" xml:lang="{@xml:lang}">
						<xsl:value-of select="."/>
					</span>
					<xsl:if test="string(@xml:lang)">
						<span class="lang">
							<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
						</span>
					</xsl:if>
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

	<xsl:function name="nomisma:normalize_date">
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
