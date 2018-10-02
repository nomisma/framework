<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:org="http://www.w3.org/ns/org#" xmlns:nomisma="http://nomisma.org/"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="html-templates.xsl"/>
	<xsl:include href="../../vis-templates.xsl"/>

	<!-- config or other variables -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="mode">record</xsl:variable>
	<xsl:variable name="type" select="/content/rdf:RDF/*[1]/name()"/>
	<xsl:variable name="id" select="if ($type = 'skos:ConceptScheme') then tokenize(/content/rdf:RDF/*[1]/@rdf:about, '/')[last() -1] else tokenize(/content/rdf:RDF/*[1]/@rdf:about, '/')[last()]"/>	
	<xsl:variable name="title" select="/content/rdf:RDF/*[1]/skos:prefLabel[@xml:lang = 'en']"/>

	<!-- sparql -->
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_query"/>

	<!-- definition of namespaces for turning in solr type field URIs into abbreviations -->
	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="//rdf:RDF/namespace::*[not(name() = 'xml')]">
				<namespace prefix="{name()}" uri="{.}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>

	<!-- variables to determine whether the map should show when mints or findspots exist or whether the quantitative analysis functions should be included -->
	<xsl:variable name="hasMints" as="xs:boolean" select="
			if (/content/res:sparql[1]/res:boolean = 'true') then
				true()
			else
				false()"/>
	<xsl:variable name="hasFindspots" as="xs:boolean" select="
			if (/content/res:sparql[2]/res:boolean = 'true') then
				true()
			else
				false()"/>
	<xsl:variable name="hasTypes" as="xs:boolean" select="
			if (/content/res:sparql[3]/res:boolean = 'true') then
				true()
			else
				false()"/>

	<xsl:variable name="classes" as="item()*">
		<classes>
			<class map="false" types="false" prop="nmo:hasCollection">nmo:Collection</class>
			<class map="true" types="true" prop="nmo:hasDenomination" dist="true">nmo:Denomination</class>
			<class map="true" types="true" prop="?prop">rdac:Family</class>
			<class map="true" types="false">nmo:Ethnic</class>
			<class map="false" types="false">nmo:FieldOfNumismatics</class>
			<class map="true" types="false">nmo:Hoard</class>
			<class map="true" types="true" prop="nmo:hasManufacture" dist="true">nmo:Manufacture</class>
			<class map="true" types="true" prop="nmo:hasMaterial" dist="true">nmo:Material</class>
			<class map="true" types="true" prop="nmo:hasMint" dist="true">nmo:Mint</class>
			<class map="false" types="false">nmo:NumismaticTerm</class>
			<class map="true" types="false">nmo:ObjectType</class>
			<class map="true" types="true" prop="?prop">foaf:Group</class>
			<class map="true" types="true" prop="?prop" dist="true">foaf:Organization</class>
			<class map="true" types="true" prop="?prop" dist="true">foaf:Person</class>
			<class map="false" types="false">crm:E4_Period</class>
			<class>nmo:ReferenceWork</class>
			<class map="true" types="true" prop="nmo:hasRegion" dist="true">nmo:Region</class>
			<class map="false" types="false">org:Role</class>
			<class map="false" types="false">nmo:TypeSeries</class>
			<class map="false" types="false">un:Uncertainty</class>
			<class map="false" types="false">nmo:CoinWear</class>
			<prop>nmo:hasAuthority</prop>
			<prop>nmo:hasIssuer</prop>
			<prop>portrait</prop>
		</classes>
	</xsl:variable>

	<xsl:variable name="prefix">
		<xsl:for-each select="$namespaces/namespace">
			<xsl:value-of select="concat(@prefix, ': ', @uri)"/>
			<xsl:if test="not(position() = last())">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="base-query" select="concat($classes//class[text() = $type]/@prop, ' nm:', $id)"/>

	<xsl:template match="/">
		<html lang="en" prefix="{$prefix}" itemscope=""
			itemtype="http://schema.org/{if (contains($type, 'foaf:')) then substring-after($type, 'foaf:') else if ($type='nmo:Mint' or $type='nmo:Region')
			then 'Place' else 'Thing'}">
			<head>
				<title id="{$id}">nomisma.org: <xsl:value-of select="$id"/></title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="http://code.jquery.com/jquery-2.1.4.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>

				<!-- include geographic js if there are mints or findspots to render -->
				<xsl:if test="$hasMints = true() or $hasFindspots = true()">
					<link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.css"/>
					<script src="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/leaflet.ajax.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/heatmap.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/leaflet-heatmap.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/display_map_functions.js"/>
				</xsl:if>

				<!-- add d3 if it is a graph-enabled class -->
				<xsl:if test="$classes//class[text() = $type]/@dist = true()">
					<script type="text/javascript" src="https://d3plus.org/js/d3.js"/>
					<script type="text/javascript" src="https://d3plus.org/js/d3plus.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/vis_functions.js"/>
				</xsl:if>

				<link rel="stylesheet" href="{$display_path}ui//css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$display_path}ui//javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/display_functions.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
				
				<!-- google analytics -->
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>

				<!-- schema.org metadata -->
				<xsl:for-each select="descendant::skos:prefLabel">
					<meta itemprop="name" content="{.}" lang="{@xml:lang}"/>
				</xsl:for-each>
				<xsl:for-each select="descendant::skos:definition">
					<meta itemprop="description" content="{.}" lang="{@xml:lang}"/>
				</xsl:for-each>
				<meta itemprop="url" content="{descendant::skos:inScheme/@rdf:resource, $id}"/>
				<xsl:for-each select="descendant::skos:exactMatch | descendant::skos:closeMatch">
					<meta itemprop="sameAs" content="{@rdf:resource}"/>
				</xsl:for-each>
				<xsl:if test="$type = 'nmo:Mint' and descendant::geo:lat">
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
				<div class="col-md-{if ($hasMints = true() or $hasFindspots = true()) then '6' else '9'}">
					<xsl:if test="$hasTypes = true()">
						<a href="#quant">Quantitative Analysis</a>
					</xsl:if>
					
					<xsl:apply-templates select="/content/rdf:RDF/*[not(name() = 'dcterms:ProvenanceStatement')]" mode="type">
						<xsl:with-param name="mode">record</xsl:with-param>
					</xsl:apply-templates>
					
					<!-- ProvenanceStatement is hidden by default -->
					<xsl:if test="/content/rdf:RDF/dcterms:ProvenanceStatement">
						<h3>
							<xsl:text>Data Provenance</xsl:text>
							<small>
								<a href="#" class="toggle-button" id="toggle-provenance" title="Click to hide or show the provenance">
									<span class="glyphicon glyphicon-triangle-right"/>
								</a>
							</small>
						</h3>
						<div style="display:none" id="provenance">
							<xsl:apply-templates select="/content/rdf:RDF/*[name() = 'dcterms:ProvenanceStatement']" mode="type">
								<xsl:with-param name="mode">record</xsl:with-param>
							</xsl:apply-templates>
						</div>
					</xsl:if>
				</div>
				<div class="col-md-{if ($hasMints = true() or $hasFindspots = true()) then '6' else '3'}">					
					<div>
						<h3>Export</h3>
						<ul class="list-inline">
							<li>
								<strong>Linked Data</strong>
							</li>
							<li>
								<a href="https://github.com/nomisma/data/blob/master/{if ($type = 'skos:ConceptScheme') then '' else concat(tokenize(//rdf:RDF/*[1]/@rdf:about, '/')[last() - 1], '/')}{$id}.rdf">GitHub File</a>
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
						<xsl:if test="$hasMints = true() or $hasFindspots = true()">
							<ul class="list-inline">
								<li>
									<strong>Geographic Data</strong>
								</li>
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
					<xsl:if test="$hasMints = true() or $hasFindspots = true()">
						<!--<div id="mapcontainer"/>-->
						<div id="mapcontainer" class="map-normal">
							<div id="info"/>
						</div>
						<div style="margin:10px 0">
							<table>
								<tbody>
									<tr>
										<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
										<td style="width:100px;padding-left:6px;">Mints</td>
										<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
										<td style="width:100px;padding-left:6px;">Hoards</td>
										<td style="background-color:#a1d490;border:2px solid black;width:50px;"/>
										<td style="width:100px;padding-left:6px;">Finds</td>
										<td>
											<a href="{$display_path}map/{$id}">View fullscreen</a>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					</xsl:if>
				</div>
			</div>
			<!-- list of associated coin types and example coins -->
			<xsl:if test="$hasTypes = true()">
				<div class="row">
					<div class="col-md-12 page-section">
						<hr/>
						<div id="listTypes"/>
					</div>
				</div>
			</xsl:if>

			<!-- display quantitative analysis template if there are coin types associated with the concept -->
			<xsl:if test="$hasTypes = true()">
				<div class="row">
					<div class="col-md-12 page-section" id="quant">
						<h2>Quantitative Analysis</h2>
						<xsl:call-template name="distribution-form">
							<xsl:with-param name="mode" select="$mode"/>
						</xsl:call-template>
						<xsl:call-template name="metrical-form">
							<xsl:with-param name="mode" select="$mode"/>
						</xsl:call-template>
					</div>
				</div>
			</xsl:if>
		</div>

		<!-- variables retrieved from the config and used in javascript -->
		<div class="hidden">
			<span id="mapboxKey">
				<xsl:value-of select="/content/config/mapboxKey"/>
			</span>
			<span id="type">
				<xsl:value-of select="$type"/>
			</span>
			<span id="page">
				<xsl:value-of select="$mode"/>
			</span>
			<span id="base-query">
				<xsl:value-of select="$base-query"/>
			</span>

			<xsl:call-template name="field-template">
				<xsl:with-param name="template" as="xs:boolean">true</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="compare-container-template">
				<xsl:with-param name="template" as="xs:boolean">true</xsl:with-param>
			</xsl:call-template>
			
			<xsl:call-template name="date-template">
				<xsl:with-param name="template" as="xs:boolean">true</xsl:with-param>
			</xsl:call-template>

			<xsl:call-template name="ajax-loader-template"/>
		</div>
	</xsl:template>
</xsl:stylesheet>
