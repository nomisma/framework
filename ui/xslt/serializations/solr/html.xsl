<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>

	<!-- request params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="rows">100</xsl:param>
	<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
	<xsl:param name="start">
		<xsl:choose>
			<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='start']/value)">
				<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- variables -->
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>
	<xsl:variable name="feed_url">
		<xsl:text>feed/</xsl:text>
		<xsl:if test="string($q) or string($sort)">?</xsl:if>
		<xsl:if test="string($q)">q=<xsl:value-of select="$q"/><xsl:if test="string($sort)">&amp;</xsl:if></xsl:if>
		<xsl:if test="string($sort)">sort=<xsl:value-of select="$sort"/></xsl:if>
	</xsl:variable>
	<xsl:variable name="display_path"/>

	<!-- definition of namespaces for turning in solr type field URIs into abbreviations -->
	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<namespace prefix="ecrm" uri="http://erlangen-crm.org/current/"/>
			<namespace prefix="dcterms" uri="http://purl.org/dc/terms/"/>
			<namespace prefix="foaf" uri="http://xmlns.com/foaf/0.1/"/>
			<namespace prefix="geo" uri="http://www.w3.org/2003/01/geo/wgs84_pos#"/>
			<namespace prefix="nm" uri="http://nomisma.org/id/"/>
			<namespace prefix="nmo" uri="http://nomisma.org/ontology#"/>
			<namespace prefix="org" uri="http://www.w3.org/ns/org#"/>
			<namespace prefix="osgeo" uri="http://data.ordnancesurvey.co.uk/ontology/geometry/"/>
			<namespace prefix="rdac" uri="http://www.rdaregistry.info/Elements/c/"/>
			<namespace prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
			<namespace prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>
			<namespace prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
			<namespace prefix="xsd" uri="http://www.w3.org/2001/XMLSchema#"/>
			<namespace prefix="un" uri="http://www.owl-ontologies.com/Ontology1181490123.owl#"/>
		</namespaces>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: Browse</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/result_functions.js"/>
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
				<link rel="alternate" type="application/atom+xml" href="{$feed_url}"/>
				<!-- opensearch compliance -->
				<link rel="search" type="application/opensearchdescription+xml" href="http://nomisma.org/opensearch.xml" title="Example Search"/>
				<meta name="totalResults" content="{$numFound}"/>
				<meta name="startIndex" content="{$start_var}"/>
				<meta name="itemsPerPage" content="{$rows}"/>
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
					<h1>Browse Nomisma IDs</h1>

					<xsl:call-template name="filter"/>
					<xsl:choose>
						<xsl:when test="$numFound &gt; 0">
							<xsl:call-template name="export"/>
							<xsl:call-template name="paging"/>
							<xsl:apply-templates select="descendant::doc"/>
							<xsl:call-template name="paging"/>
						</xsl:when>
						<xsl:otherwise>
							<p>No results found for this query. <a href="../browse">Clear search</a>.</p>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="doc">
		<div class="result-doc">
			<h4>
				<a href="id/{str[@name='id']}" title="{if(string(str[@name='prefLabel'])) then str[@name='prefLabel'] else str[@name='id']}">
					<xsl:value-of select="if(string(str[@name='prefLabel'])) then str[@name='prefLabel'] else str[@name='id']"/>
				</a>
			</h4>
			<xsl:if test="string(str[@name='definition']) or not(contains($q, 'type'))">
				<dl class="dl-horizontal">
					<xsl:if test="string(str[@name='definition'])">
						<dt>Definition</dt>
						<dd>
							<xsl:value-of select="str[@name='definition']"/>
						</dd>
					</xsl:if>
					<xsl:if test="not(contains($q, 'type'))">
						<dt>Type</dt>
						<dd>
							<xsl:for-each select="arr[@name='type']/str">
								<xsl:variable name="name" select="."/>

								<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}">
									<xsl:value-of select="$name"/>
								</a>
								<xsl:if test="not(position()=last())">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</dd>
					</xsl:if>
				</dl>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="filter">
		<form action="browse" class="form-horizontal" id="filter-form" method="get">
			<div class="form-group">
				<label for="search_text" class="col-sm-2 control-label">Keyword</label>
				<div class="col-sm-10">
					<input type="text" class="form-control" id="search_text" placeholder="Keyword"/>
					<a href="#" id="toggle-filters" class="toggle-button" title="More Filters" style="margin-left:10px;">
						<xsl:text>Filters</xsl:text>
						<span class="glyphicon glyphicon-triangle-{if (not(contains($q, 'type:')) and not(contains($q, '_facet:')) and not(string($sort))) then 'right' else 'bottom'}"/>
					</a>
				</div>
			</div>

			<!-- additional filters -->
			<div id="filters-div">
				<xsl:if test="not(contains($q, 'type:')) and not(contains($q, '_facet:')) and not(string($sort))">
					<xsl:attribute name="style">display:none</xsl:attribute>
				</xsl:if>
				<div class="form-group">
					<label for="filter_type" class="col-sm-2 control-label">Concept Type</label>
					<div class="col-sm-10">
						<select id="type_filter" class="form-control">
							<option value="">Select Type...</option>
							<xsl:for-each select="descendant::lst[@name='type']/int[not(@name='skos:Concept')]">
								<xsl:variable name="value" select="concat('type:&#x022;', @name, '&#x022;')"/>
								<option value="{$value}">
									<xsl:if test="contains($q, $value)">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="@name"/>
								</option>
							</xsl:for-each>
						</select>
					</div>
				</div>
				<div class="form-group role_div">
					<xsl:if test="not(contains($q, 'foaf:'))">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<label for="role_filter" class="col-sm-2 control-label">Role</label>
					<div class="col-sm-10">
						<select id="role_filter" class="form-control">
							<xsl:if test="not(contains($q, 'foaf:'))">
								<xsl:attribute name="disabled">disabled</xsl:attribute>
							</xsl:if>
							<option value="">Select Role...</option>
							<xsl:for-each select="descendant::lst[@name='role_facet']/int">
								<xsl:variable name="value" select="concat('role_facet:&#x022;', @name, '&#x022;')"/>
								<option value="{$value}">
									<xsl:if test="contains($q, $value)">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring-before(@name, '|')"/>
								</option>
							</xsl:for-each>
						</select>
					</div>
				</div>

				<div class="form-group">
					<label for="field_filter" class="col-sm-2 control-label">Field of Numismatics</label>
					<div class="col-sm-10">
						<select id="field_filter" class="form-control">
							<option value="">Select Field...</option>
							<xsl:for-each select="descendant::lst[@name='field_facet']/int">
								<xsl:variable name="value" select="concat('field_facet:&#x022;', @name, '&#x022;')"/>
								<option value="{$value}">
									<xsl:if test="contains($q, $value)">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring-before(@name, '|')"/>
								</option>
							</xsl:for-each>
						</select>
					</div>
				</div>

				<div class="form-group">
					<label for="sort_results" class="col-sm-2 control-label">Sort</label>
					<div class="col-sm-10">
						<select id="sort_results" class="form-control">
							<option value="">Relevance</option>
							<option value="prefLabel asc">
								<xsl:if test="$sort = 'prefLabel asc'">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:text>Alphabetical A↓Z</xsl:text>
							</option>
							<option value="prefLabel desc">
								<xsl:if test="$sort = 'prefLabel desc'">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:text>Alphabetical Z↓A</xsl:text>
							</option>
							<option value="timestamp desc">
								<xsl:if test="$sort = 'timestamp desc'">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:text>Modification Date (newest first)</xsl:text>
							</option>
							<option value="timestamp asc">
								<xsl:if test="$sort = 'timestamp asc'">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:text>Modification Date (oldest first)</xsl:text>
							</option>
						</select>
					</div>
				</div>
			</div>

			<div class="form-group">
				<div class="col-sm-offset-2 col-sm-10">
					<button id="search_button" class="btn btn-default">
						<span class="glyphicon glyphicon-search"/>
						<xsl:text> Search</xsl:text>
					</button>
					<xsl:if test="string($q)">
						<button class="btn btn-default" id="clear-query" style="margin-left:10px;">Clear</button>
					</xsl:if>
				</div>
			</div>

			<input name="q" type="hidden"/>
			<input name="sort" type="hidden">
				<xsl:if test="not(string($sort))">
					<xsl:attribute name="disabled">disabled</xsl:attribute>
				</xsl:if>
			</input>
			<hr/>
		</form>
	</xsl:template>

	<xsl:template name="paging">
		<xsl:variable name="start_var" as="xs:integer">
			<xsl:choose>
				<xsl:when test="string($start)">
					<xsl:value-of select="$start"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="next">
			<xsl:value-of select="$start_var+$rows"/>
		</xsl:variable>

		<xsl:variable name="previous">
			<xsl:choose>
				<xsl:when test="$start_var &gt;= $rows">
					<xsl:value-of select="$start_var - $rows"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="current" select="$start_var div $rows + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $rows)"/>

		<div class="paging_div row">
			<div class="col-md-6">
				<xsl:variable name="startRecord" select="$start_var + 1"/>
				<xsl:variable name="endRecord">
					<xsl:choose>
						<xsl:when test="$numFound &gt; ($start_var + $rows)">
							<xsl:value-of select="$start_var + $rows"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$numFound"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<span>
					<b>
						<xsl:value-of select="$startRecord"/>
					</b>
					<xsl:text> to </xsl:text>
					<b>
						<xsl:value-of select="$endRecord"/>
					</b>
					<text> of </text>
					<b>
						<xsl:value-of select="$numFound"/>
					</b>
					<xsl:text> total results.</xsl:text>
				</span>
			</div>
			<!-- paging functionality -->
			<div class="col-md-6 page-nos">
				<div class="btn-toolbar" role="toolbar">
					<div class="btn-group" style="float:right">
						<xsl:choose>
							<xsl:when test="$start_var &gt;= $rows">
								<a class="btn btn-default" title="First" href="browse?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default" title="Previous" href="browse?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="First" href="browse?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default disabled" title="Previous" href="browse?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else
									''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
						<!-- current page -->
						<button type="button" class="btn btn-default disabled">
							<b>
								<xsl:value-of select="$current"/>
							</b>
						</button>
						<!-- next page -->
						<xsl:choose>
							<xsl:when test="$numFound - $start_var &gt; $rows">
								<a class="btn btn-default" title="Next" href="browse?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default" href="browse?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="Next" href="browse?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default disabled" href="browse?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else
									''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="export">
		<xsl:variable name="query">
			<xsl:variable name="frags" select="tokenize($q, ' AND ')"/>

			<xsl:for-each select="$namespaces//namespace">
				<xsl:value-of select="concat('PREFIX ', @prefix, ': &lt;', @uri, '&gt;&#x000a;')"/>
			</xsl:for-each>

			<xsl:text>SELECT ?uri ?label ?definition</xsl:text>
			<xsl:if test="not($frags[contains(., 'type:')])">
				<xsl:text> ?type</xsl:text>
			</xsl:if>
			<!-- display lat and long if applicable -->
			<xsl:if test="$frags[. = 'type:&#x022;nmo:Mint&#x022;']">
				<xsl:text> ?lat ?long</xsl:text>
			</xsl:if>

			<xsl:text> WHERE {&#x000a;</xsl:text>
			<xsl:text>?uri skos:prefLabel ?label FILTER langMatches(lang(?label), "en") .&#x000a;</xsl:text>
			<xsl:text>OPTIONAL {?uri skos:definition ?definition FILTER langMatches(lang(?definition), "en")}&#x000a;</xsl:text>
			<!-- display the type of concept if the type isn't in the query -->
			<xsl:if test="not($frags[contains(., 'type:')])">
				<xsl:text>?uri rdf:type ?type FILTER regex(str(?type), "^((?!Concept).)*$")&#x000a;</xsl:text>
			</xsl:if>

			<xsl:if test="count($frags) &gt; 0">
				<xsl:text>?uri </xsl:text>
				<xsl:for-each select="$frags">
					<xsl:variable name="field" select="substring-before(., ':')"/>
					<xsl:variable name="value" select="replace(substring-after(., ':'), '&#x022;', '')"/>

					<xsl:choose>
						<xsl:when test="$field = 'type'">
							<xsl:value-of select="concat('rdf:type ', $value)"/>
						</xsl:when>
						<xsl:when test="$field = 'role_facet'"><![CDATA[org:hasMembership ?membership . 
	?membership org:role <]]><xsl:value-of select="substring-after($value, '|')"/><![CDATA[>]]></xsl:when>
						<xsl:when test="$field = 'field_facet'"><![CDATA[dcterms:isPartOf <]]><xsl:value-of select="substring-after($value, '|')"/><![CDATA[>]]></xsl:when>
					</xsl:choose>
					<xsl:if test="not(position()=last())"> ;&#x000a;</xsl:if>
				</xsl:for-each>
			</xsl:if>

			<!-- get lat and long when filtering for mints -->
			<xsl:if test="$frags[. = 'type:&#x022;nmo:Mint&#x022;']"> .&#x000a;<![CDATA[OPTIONAL {?uri geo:location ?loc . 
	?loc geo:lat ?lat ; geo:long ?long}]]></xsl:if>

			<xsl:text>&#x000a;} ORDER BY ASC(?label)</xsl:text>
		</xsl:variable>



		<div class="row">
			<div class="col-md-12 text-right">
				<a href="{$display_path}query?query={encode-for-uri($query)}&amp;output=csv" title="Download CSV" class="btn btn-primary" style="margin-bottom:10px">
					<span class="glyphicon glyphicon-download"/>Download CSV</a>
				<a href="{$feed_url}" class="btn btn-primary" style="margin:0 0 10px 10px">Atom Feed</a>
				<button class="btn btn-primary toggle-button" id="toggle-sparql" style="margin:0 0 10px 10px">Toggle SPARQL Query</button>
			</div>

			<div id="sparql-div" class="col-md-12" style="display:none">
				<p class="bg-warning" style="padding:15px"><span class="glyphicon glyphicon-alert"/>
					<strong>Note:</strong> Keyword searching is not yet supported in the SPARQL endpoint.</p>
				<pre>
					<xsl:value-of select="$query"/>
				</pre>
			</div>

		</div>
	</xsl:template>

</xsl:stylesheet>
