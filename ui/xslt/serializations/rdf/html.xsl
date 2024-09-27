<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date modified: July 2021
	Function: Serialize RDF into HTML. This applies to creating human readable pages out of RDF/XML for Nomisma IDs -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:org="http://www.w3.org/ns/org#" xmlns:nomisma="http://nomisma.org/"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:prov="http://www.w3.org/ns/prov#"
	xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="html-templates.xsl"/>
	<xsl:include href="../../vis-templates.xsl"/>
	
	<xsl:param name="lang">en</xsl:param>

	<!-- config or other variables -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:param name="mode">record</xsl:param>
	<xsl:variable name="type" select="/content/rdf:RDF/*[1]/name()"/>
	<xsl:variable name="conceptURI" select="/content/rdf:RDF/*[1]/@rdf:about"/>
	<xsl:variable name="id"
		select="
			if ($type = 'skos:ConceptScheme') then
				tokenize($conceptURI, '/')[last() - 1]
			else
				tokenize($conceptURI, '/')[last()]"/>
	<xsl:variable name="scheme" select="
			if ($type = 'skos:ConceptScheme') then
				''
			else
				tokenize($conceptURI, '/')[last() - 1]"/>

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
	<xsl:variable name="hasFindspots" as="xs:boolean" select="if (descendant::nmo:hasFindspot) then true() 
			else if (/content/res:sparql[2]/res:boolean = 'true') then
				true()
			else
				false()"/>
	<xsl:variable name="hasTypes" as="xs:boolean" select="
			if (/content/res:sparql[3]/res:boolean = 'true') then
				true()
			else
				false()"/>	

	<xsl:variable name="prefix">
		<xsl:for-each select="$namespaces/namespace">
			<xsl:value-of select="concat(@prefix, ': ', @uri)"/>
			<xsl:if test="not(position() = last())">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="base-query" select="concat(/content/config/classes/class[text() = $type]/@prop, ' nm:', $id)"/>

	<xsl:template match="/">
		<html lang="en" prefix="{$prefix}" itemscope=""
			itemtype="http://schema.org/{if (contains($type, 'foaf:')) then substring-after($type, 'foaf:') else if ($type='nmo:Mint' or $type='nmo:Region')
			then 'Place' else 'Thing'}">
			<head>
				<title id="{$id}">nomisma.org: <xsl:value-of select="$id"/></title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.4.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>

				<!-- include geographic js if there are mints or findspots to render -->
				<xsl:if test="$hasMints = true() or $hasFindspots = true()">
					<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
					<script type="text/javascript" src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/leaflet.ajax.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/display_map_functions.js"/>
				</xsl:if>

				<!-- add d3 if it is a graph-enabled class -->
				<xsl:if test="/content/config/classes/class[text() = $type]/@dist = true()">
					<script type="text/javascript" src="{$display_path}ui/javascript/d3.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/d3plus.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/vis_functions.js"/>
				</xsl:if>
				
				<xsl:if test="$type = 'nmo:Monogram' or $type = 'crm:E37_Mark'">
					<script type="text/javascript" src="{$display_path}ui/javascript/d3.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/d3plus-network.full.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/network_functions.js"/>					
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
					<xsl:call-template name="rdf-display-structure"/>
				</div>

				<!-- data export and map -->
				<div class="col-md-{if ($hasMints = true() or $hasFindspots = true()) then '6' else '3'}">
					<div>
						<h3>Export</h3>
						<ul class="list-inline">
							<li>
								<strong>Linked Data</strong>
							</li>
							<li>
								<a
									href="https://github.com/nomisma/data/blob/master/{if ($type = 'skos:ConceptScheme') then '' else concat(tokenize(//rdf:RDF/*[1]/@rdf:about, '/')[last() - 1], '/')}{$id}.rdf"
									>GitHub File</a>
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
						</ul>

						<!-- insert a DataCite XML link for an editor with IDs -->
						<xsl:if test="$scheme = 'editor'">
							<xsl:if test="doc('input:id-count')//res:binding[@name = 'count']/res:literal &gt; 0">
								<div class="text-right">
									<a href="{$id}.xml" title="DataCite XML Metadata">
										<img src="{$display_path}ui/images/datacite-medium.png" alt="DataCite Logo: https://datacite.org/"/>
									</a>
									<br/>
									<a href="{$id}.xml">DataCite XML Metadata</a>
								</div>
							</xsl:if>
						</xsl:if>

						<xsl:if test="$hasMints = true() or $hasFindspots = true()">
							<ul class="list-inline">
								<li>
									<strong>Geographic Data</strong>
								</li>
								<li>
									<a href="{$id}.kml">KML</a>
								</li>
								<li>
									<a href="{$id}.geojson">GeoJSON</a>
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
										<td style="background-color:#f98f0c;border:2px solid black;width:50px;"/>
										<td style="width:100px;padding-left:6px;">Finds</td>
										<td>
											<a href="{$display_path}{if ($type = 'nmo:Monogram' or $type = 'crm:E37_Mark') then 'symbol' else ''}map/{$id}">View fullscreen</a>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
					</xsl:if>
				</div>
			</div>

			<!-- optional contexts -->
			<xsl:choose>
				<xsl:when test="$scheme = 'id' or $scheme = 'symbol'">
					
					<xsl:if test="$scheme = 'symbol'">
						<div class="section">
							<h3>Network Graph</h3>
							<div style="margin:10px 0">
								<table>
									<tbody>
										<tr>
											<td style="background-color:#a8a8a8;border:2px solid black;width:50px;"/>
											<td style="width:100px">This Symbol</td>
											<td style="background-color:#6985c6;border:2px solid black;width:50px;"/>
											<td style="width:100px">Immediate Link</td>
											<td style="background-color:#b3c9fc;border:2px solid black;width:50px;"/>
											<td style="width:100px">Secondary Link</td>
										</tr>
									</tbody>
								</table>
							</div>
							<div class="network-graph hidden" id="{generate-id()}"/>
						</div>
					</xsl:if>					
					
					<!-- list of associated coin types and example coins -->
					<xsl:if test="$hasTypes = true()">
						<div class="row">
							<div class="col-md-12 page-section">
								<hr/>
								<div id="listTypes"/>
							</div>
						</div>
					</xsl:if>
					
					<xsl:if test="$type = 'foaf:Organization'">
						<div class="row">
							<div class="col-md-12 page-section">
								<hr/>
								<div id="listAgents"/>
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
				</xsl:when>
				<xsl:when test="$scheme = 'editor'">
					<xsl:if test="doc('input:id-count')//res:binding[@name = 'count']/res:literal &gt; 0">
						<xsl:variable name="count" select="doc('input:id-count')//res:binding[@name = 'count']/res:literal"/>
						<div class="row">
							<div class="col-md-12 page-section">
								<hr/>
								<h2>Nomisma Contributions</h2>
								<xsl:apply-templates select="doc('input:spreadsheet-list')/rdf:RDF[count(prov:Entity) &gt; 0]" mode="spreadsheets"/>
								<xsl:apply-templates select="doc('input:id-list')/res:sparql" mode="edited-ids">
									<xsl:with-param name="count" select="$count"/>
								</xsl:apply-templates>
							</div>
						</div>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<!-- context for ConceptSchemes -->
					<xsl:choose>
						<xsl:when test="$id = 'editor'">
							<xsl:apply-templates select="doc('input:editors')/res:sparql[count(descendant::res:result) &gt; 0]" mode="editors"/>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
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
			<span id="conceptURI">
				<xsl:value-of select="$conceptURI"/>
			</span>
			<span id="path"/>

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

	<xsl:template name="rdf-display-structure">
		<xsl:apply-templates select="/content/rdf:RDF/*[1]" mode="human-readable">
			<xsl:with-param name="mode">record</xsl:with-param>
		</xsl:apply-templates>
		
		<!-- separate template for Digital Images for symbols -->
		<xsl:if test="/content//crmdig:D1_Digital_Object">
			<div>
				<h3>Digital Images</h3>
				
				<table class="table table-striped">
					<thead>
						<th style="width:120px">Image</th>
						<th>Metadata</th>
					</thead>
					<tbody>
						<xsl:apply-templates select="/content//crmdig:D1_Digital_Object"/>
					</tbody>
				</table>
				
			</div>
		</xsl:if>
		
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
					<xsl:with-param name="hasObjects" select="false()" as="xs:boolean"/>
					<xsl:with-param name="mode">record</xsl:with-param>
				</xsl:apply-templates>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Related ID and spreadsheet templates for enhancing context of /editor pages -->
	<xsl:template match="rdf:RDF" mode="spreadsheets">

		<!-- load SPARQL as text -->
		<xsl:variable name="query" select="doc('input:getSpreadsheets-query')"/>

		<h3>Spreadsheets</h3>
		<p>This editor has contributed Nomisma IDs through the following spreadsheets (<a
				href="{$display_path}query?query={encode-for-uri(replace($query, '%URI%', $conceptURI))}&amp;output=json" title="Download list">
				<span class="glyphicon glyphicon-download"/> Download list</a>):</p>
		<table class="table table-striped">
			<thead>
				<tr>
					<th>Description</th>
					<th>Date</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="prov:Entity">
					<xsl:sort select="prov:atTime[1]" order="descending"/>
					<tr>
						<td>
							<a href="{@rdf:about}">
								<xsl:value-of select="dcterms:description"/>
							</a>
						</td>
						<td>
							<xsl:value-of select="format-dateTime(prov:atTime[1], '[D] [MNn] [Y0001]')"/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="res:sparql" mode="edited-ids">
		<xsl:param name="count"/>

		<!-- load SPARQL as text -->
		<xsl:variable name="query" select="doc('input:getEditedIds-query')"/>

		<xsl:variable name="describe" select="replace(replace(replace($query, '%URI%', $conceptURI), ' %LIMIT%', ''), 'SELECT', 'DESCRIBE')"/>

		<h3>Concepts</h3>
		<xsl:choose>
			<xsl:when test="$count &gt; 25">
				<p>This is a partial list of <strong>25</strong> of <strong><xsl:value-of select="$count"/></strong> IDs created or updated by this editor (<a
						href="{$display_path}query?query={encode-for-uri(replace(replace($query, '%URI%', $conceptURI), ' %LIMIT%', ''))}&amp;output=csv"
						title="Download list">
						<span class="glyphicon glyphicon-download"/> Download list</a>):</p>
			</xsl:when>
			<xsl:otherwise>
				<p>This is a list of <strong><xsl:value-of select="$count"/></strong> IDs created or updated by this editor:</p>
			</xsl:otherwise>
		</xsl:choose>

		<p>
			<strong>Download as: </strong>
			<a href="{$display_path}query?query={encode-for-uri($describe)}&amp;output=xml" title="RDF/XML">RDF/XML</a>
			<xsl:text> | </xsl:text>
			<a href="{$display_path}query?query={encode-for-uri($describe)}&amp;output=text" title="Turtle">Turtle</a>
			<xsl:text> | </xsl:text>
			<a href="{$display_path}query?query={encode-for-uri($describe)}&amp;output=json" title="JSON-LD">JSON-LD</a>
		</p>

		<table class="table table-striped">
			<thead>
				<tr>
					<th>Label</th>
					<th>Spreadsheet</th>
					<th>Date</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="descendant::res:result">
					<tr>
						<td>
							<a href="{res:binding[@name='concept']/res:uri}">
								<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
							</a>
						</td>
						<td>
							<xsl:if test="res:binding[@name = 'spreadsheet']">
								<a href="{res:binding[@name='spreadsheet']/res:uri}">
									<xsl:value-of select="res:binding[@name = 'desc']/res:literal"/>
								</a>
							</xsl:if>
						</td>
						<td>
							<xsl:value-of select="format-dateTime(res:binding[@name = 'date']/res:literal, '[D] [MNn] [Y0001]')"/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="res:sparql" mode="editors">
		<div class="row">
			<div class="col-md-12 page-section">
				<hr/>
				<h2>Editors</h2>
				<table class="table table-striped">
					<thead>
						<tr>
							<th>Name</th>
							<th>ORCID</th>
							<th>Last Edit</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="descendant::res:result">
							<tr>
								<td>
									<a href="{res:binding[@name='editor']/res:uri}">
										<xsl:value-of select="res:binding[@name = 'name']/res:literal"/>
									</a>
								</td>
								<td>
									<xsl:if test="res:binding[@name = 'orcid']">
										<a href="{res:binding[@name='orcid']/res:uri}">
											<xsl:value-of select="tokenize(res:binding[@name = 'orcid']/res:uri, '/')[last()]"/>
										</a>
									</xsl:if>
								</td>
								<td>
									<xsl:value-of select="format-dateTime(res:binding[@name = 'update']/res:literal, '[D] [MNn] [Y0001]')"/>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
