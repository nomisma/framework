<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>

	<!-- request params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="rows">100</xsl:param>
	<xsl:param name="sort">
		<xsl:if test="string(doc('input:request')/request/parameters/parameter[name='sort']/value)">
			<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
		</xsl:if>
	</xsl:param>
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
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>
	<xsl:variable name="display_path">../</xsl:variable>

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
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
				<link rel="alternate" type="application/atom+xml" href="feed/{if ($q = '*:*') then '' else concat('./?q=', $q)}"/>
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
					<h1>Results</h1>
					<xsl:call-template name="filter"/>
					<xsl:choose>
						<xsl:when test="$numFound &gt; 0">
							<xsl:call-template name="paging"/>
							<xsl:apply-templates select="descendant::doc"/>
							<xsl:call-template name="paging"/>
						</xsl:when>
						<xsl:otherwise>
							<p>No results found for this query. <a href="../id/">Clear search</a>.</p>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="doc">
		<div class="result-doc row">
			<h4>
				<a href="{str[@name='id']}" title="{if(string(str[@name='prefLabel'])) then str[@name='prefLabel'] else str[@name='id']}">
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
								<xsl:variable name="uri" select="."/>

								<a href="{.}">
									<xsl:value-of
										select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
									/>
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
		<form action="." class="filter-form" method="get">
			<span>
				<b>Filter: </b>
			</span>
			<select id="search_filter" class="form-control">
				<option value="">Select Type...</option>
				<xsl:for-each select="descendant::lst[@name='type']/int[not(@name='http://www.w3.org/2004/02/skos/core#Concept')]">
					<xsl:variable name="uri" select="@name"/>
					<xsl:variable name="value" select="concat('type:&#x022;', $uri, '&#x022;')"/>
					<option value="{$value}">
						<xsl:if test="contains($q, $value)">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>
						<xsl:value-of
							select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
						/>
					</option>
				</xsl:for-each>
			</select>
			<span>
				<b>Keyword: </b>
			</span>
			<input type="text" id="search_text" class="form-control" placeholder="Search">
				<xsl:if test="$tokenized_q[not(contains(., 'type'))]">
					<xsl:attribute name="value" select="$tokenized_q[not(contains(., 'type'))]"/>
				</xsl:if>
			</input>
			<input name="q" type="hidden"/>
			<button id="search_button" class="btn btn-default"><span class="glyphicon glyphicon-search"/></button>
		</form>
		<xsl:if test="string($q)">
			<form action="../id/" method="get" class="filter-form">
				<button class="btn btn-default" style="margin-left:10px;">Clear</button>
			</form>
		</xsl:if>
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
								<a class="btn btn-default" title="First"
									href="./?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default" title="Previous"
									href="./?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="First"
									href="./?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default disabled" title="Previous"
									href="./?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
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
								<a class="btn btn-default" title="Next"
									href="./?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default"
									href="./?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="Next"
									href="./?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default disabled"
									href="./?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
