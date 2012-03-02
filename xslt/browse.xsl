<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs exsl xs xi" version="2.0"
	xmlns:xi="http://www.w3.org/2001/XInclude" xmlns="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common">
	<xsl:include href="header-public.xsl"/>
	<xsl:include href="footer-public.xsl"/>

	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'nomisma/config.xml'))"/>
	<xsl:variable name="solr-url" select="concat(exsl:node-set($config)/config/solr_url, 'select/')"/>
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="pipeline">results</xsl:variable>

	<!-- URL parameters -->
	<xsl:param name="query">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='query']/value[1]"/>
	</xsl:param>
	<xsl:param name="exclude">
		<xsl:if test="count(doc('input:params')/request/parameters/parameter[name='exclude']/value) &gt; 0">
			<xsl:text>NOT (</xsl:text>
			<xsl:for-each select="doc('input:params')/request/parameters/parameter[name='exclude']/value">
				<xsl:text>typeof:"</xsl:text>
				<xsl:value-of select="."/>
				<xsl:text>"</xsl:text>
				<xsl:if test="not(position()=last())">
					<xsl:text> OR </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:param>
	<xsl:variable name="q">
		<xsl:choose>
			<xsl:when test="string($query) or string($exclude)">
				<xsl:if test="string($query)">
					<xsl:value-of select="concat('fulltext:', $query)"/>
				</xsl:if>
				<xsl:if test="string($query) and string($exclude)">
					<xsl:text> AND </xsl:text>
				</xsl:if>
				<xsl:if test="string($exclude)">
					<xsl:value-of select="$exclude"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>*:*</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="encoded_q" select="encode-for-uri($q)"/>

	<xsl:param name="sort">
		<xsl:choose>
			<xsl:when test="string(doc('input:params')/request/parameters/parameter[name='sort']/value)">
				<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='sort']/value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>prefLabel asc</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="encoded_sort" select="encode-for-uri($sort)"/>
	<xsl:param name="rows">100</xsl:param>
	<xsl:param name="start">
		<xsl:choose>
			<xsl:when test="string(doc('input:params')/request/parameters/parameter[name='start']/value)">
				<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='start']/value"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>




	<!-- request URL -->
	<xsl:param name="base-url" select="substring-before(doc('input:url')/request/request-url, 'results/')"/>

	<!-- Solr query URL -->
	<xsl:variable name="service">
		<xsl:value-of select="concat($solr-url, '?q=', $encoded_q, '&amp;start=', $start, '&amp;sort=', $encoded_sort, '&amp;facet=true&amp;facet.field=typeof&amp;facet.sort=index')"/>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:text>nomisma.org: Search Results</xsl:text>
				</title>
				<!-- styling -->
				<link rel="stylesheet" type="text/css" href="{$display_path}css/grids-min.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}css/reset-fonts-grids.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}css/base-min.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}css/fonts-min.css"/>

				<link rel="stylesheet" href="{$display_path}css/style.css"/>

				<!-- javascript -->
				<script type="text/javascript" src="{$display_path}javascript/jquery-1.6.1.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/browse_functions.js"/>
			</head>
			<body class="yui-skin-sam">
				<div id="doc4" class="yui-t1">
					<!-- header -->
					<xsl:call-template name="header-public"/>

					<div id="bd">
						<xsl:apply-templates select="document($service)/response"/>
					</div>

					<!-- footer -->
					<xsl:call-template name="footer-public"/>
				</div>
			</body>
		</html>


	</xsl:template>

	<xsl:template match="response">
		<div id="yui-main">
			<div class="yui-b">
				<xsl:if test="not($q = '*:*')">
					<div>
						<a href="{$display_path}browse/">Clear Results</a>
					</div>
				</xsl:if>
				<!--<xsl:value-of select="$q"/>-->
				<xsl:choose>
					<xsl:when test="result[@name='response']/@numFound &gt; 0">
						<xsl:call-template name="paging"/>
						<xsl:apply-templates select="descendant::doc"/>
						<xsl:call-template name="paging"/>
					</xsl:when>
					<xsl:otherwise>
						<p>No results found.</p>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
		<div class="yui-b">
			<xsl:if test="result[@name='response']/@numFound &gt; 0">
				<div class="data_options">
					<h3>Data Options</h3>
					<a href="{$display_path}feed/?q={$q}">
						<img alt="Atom" title="Atom" src="{$display_path}images/atom-medium.png"/>
					</a>
				</div>
				<h3>Refine Results</h3>
				<form action="{$display_path}browse/" method="GET">					
					<xsl:call-template name="quick_search"/>
					<xsl:apply-templates select="descendant::lst[@name='typeof']"/>
					<input id="search_button" type="submit" value="Update"/>
				</form>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="class">
			<xsl:choose>
				<xsl:when test="position() mod 2 = 0">even</xsl:when>
				<xsl:when test="position() mod 2 = 1">odd</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<div class="result-doc {$class}">
			<a href="{$display_path}id/{str[@name='id']}">
				<xsl:value-of select="str[@name='prefLabel']"/>
			</a>
			<span class="typeof">
				<xsl:for-each select="arr[@name='typeof']/str">
					<xsl:value-of select="."/>
					<xsl:if test="not(position()=last())">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</span>
			<xsl:if test="count(arr[@name='altLabel']/str) &gt; 0">
				<br/>
				<xsl:text>Also known as: </xsl:text>
				<xsl:for-each select="arr[@name='altLabel']/str">
					<xsl:value-of select="."/>
					<xsl:if test="not(position()=last())">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="paging">
		<xsl:variable name="start_var">
			<xsl:choose>
				<xsl:when test="string($start)">
					<xsl:value-of select="$start"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="numFound">
			<xsl:value-of select="//result[@name='response']/@numFound"/>
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

		<!-- generate query-string -->
		<xsl:variable name="query_string">
			<xsl:if test="string($query)">
				<xsl:value-of select="concat('query=', $query)"/>
				<xsl:text>&amp;</xsl:text>
			</xsl:if>
			<xsl:for-each select="doc('input:params')/request/parameters/parameter[name='exclude']/value">
				<xsl:value-of select="concat('exclude=', .)"/>
				<xsl:text>&amp;</xsl:text>
			</xsl:for-each>
		</xsl:variable>

		<div class="paging_div">
			<div style="float:left;">
				<xsl:text>Displaying records </xsl:text>
				<b>
					<xsl:value-of select="$start_var + 1"/>
				</b>
				<xsl:text> to </xsl:text>
				<xsl:choose>
					<xsl:when test="$numFound &gt; ($start_var + $rows)">
						<b>
							<xsl:value-of select="$start_var + $rows"/>
						</b>
					</xsl:when>
					<xsl:otherwise>
						<b>
							<xsl:value-of select="$numFound"/>
						</b>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> of </xsl:text>
				<b>
					<xsl:value-of select="$numFound"/>
				</b>
				<xsl:text> total results.</xsl:text>
			</div>

			<!-- paging functionality -->
			<div style="float:right;">
				<xsl:choose>
					<xsl:when test="$start_var &gt;= $rows">
						<xsl:choose>
							<xsl:when test="string($sort)">
								<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$previous}&amp;sort={$sort}">«Previous</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$previous}">«Previous</a>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:when>
					<xsl:otherwise>
						<span class="pagingSep">«Previous</span>
					</xsl:otherwise>
				</xsl:choose>

				<!-- always display links to the first two pages -->
				<xsl:if test="$start_var div $rows &gt;= 3">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start=0&amp;sort={$sort}">
								<xsl:text>1</xsl:text>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start=0">
								<xsl:text>1</xsl:text>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>
				<xsl:if test="$start_var div $rows &gt;= 4">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$rows}&amp;sort={$sort}">
								<xsl:text>2</xsl:text>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$rows}">
								<xsl:text>2</xsl:text>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>

				<!-- display only if you are on page 6 or greater -->
				<xsl:if test="$start_var div $rows &gt;= 5">
					<span class="pagingSep">...</span>
				</xsl:if>

				<!-- always display links to the previous two pages -->
				<xsl:if test="$start_var div $rows &gt;= 2">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$start_var - ($rows * 2)}&amp;sort={$sort}">
								<xsl:value-of select="($start_var div $rows) -1"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$start_var - ($rows * 2)}">
								<xsl:value-of select="($start_var div $rows) -1"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="$start_var div $rows &gt;= 1">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$start_var - $rows}&amp;sort={$sort}">
								<xsl:value-of select="$start_var div $rows"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$start_var - $rows}">
								<xsl:value-of select="$start_var div $rows"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>

				<span class="pagingBtn">
					<b>
						<xsl:value-of select="$current"/>
					</b>
				</span>

				<!-- next two pages -->
				<xsl:if test="($start_var div $rows) + 1 &lt; $total">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$start_var + $rows}&amp;sort={$sort}">
								<xsl:value-of select="($start_var div $rows) +2"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$start_var + $rows}">
								<xsl:value-of select="($start_var div $rows) +2"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>
				<xsl:if test="($start_var div $rows) + 2 &lt; $total">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$start_var + ($rows * 2)}&amp;sort={$sort}">
								<xsl:value-of select="($start_var div $rows) +3"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$start_var + ($rows * 2)}">
								<xsl:value-of select="($start_var div $rows) +3"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>
				<xsl:if test="$start_var div $rows &lt;= $total - 6">
					<span class="pagingSep">...</span>
				</xsl:if>

				<!-- last two pages -->
				<xsl:if test="$start_var div $rows &lt;= $total - 5">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={($total * $rows) - ($rows * 2)}&amp;sort={$sort}">
								<xsl:value-of select="$total - 1"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={($total * $rows) - ($rows * 2)}">
								<xsl:value-of select="$total - 1"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="$start_var div $rows &lt;= $total - 4">
					<xsl:choose>
						<xsl:when test="string($sort)">
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={($total * $rows) - $rows}&amp;sort={$sort}">
								<xsl:value-of select="$total"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={($total * $rows) - $rows}">
								<xsl:value-of select="$total"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="$numFound - $start_var &gt; $rows">
						<xsl:choose>
							<xsl:when test="string($sort)">
								<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$next}&amp;sort={$sort}">Next»</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="pagingBtn" href="{$display_path}browse/?{$query_string}start={$next}">Next»</a>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<span class="pagingSep">Next»</span>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="lst[@name='typeof']">
		<div class="exclude">
			<h4>Included Terms</h4>
			<span class="checkall">Check All</span>/<span class="uncheckall">Uncheck All</span>
			<br/>
			<xsl:for-each select="int[string(@name)]">
				<xsl:choose>
					<xsl:when test="doc('input:params')/request/parameters/parameter[name='exclude']/value = @name">
						<input type="checkbox" name="exclude" value="{@name}" class="facet-checkbox"/>
					</xsl:when>
					<xsl:otherwise>
						<input type="checkbox" name="exclude" value="{@name}" class="facet-checkbox" checked="checked"/>
					</xsl:otherwise>
				</xsl:choose>
				<label for="exclude">
					<xsl:value-of select="@name"/>
				</label>
				<br/>
			</xsl:for-each>

		</div>
	</xsl:template>

	<xsl:template name="quick_search">
		<div class="quick_search">
			<h4>Quick Search</h4>
			<input type="text" name="query" id="qs_query" value="{$query}"/>
		</div>
	</xsl:template>

	<!--<xsl:template match="lst[@name='facet_fields']">		
		<form action="." id="facet_form">
			<input type="hidden" name="q" id="facet_form_query" value="{if (string($q)) then $q else '*:*'}"/>
			<br/>
			<div class="submit_div">
				<input type="submit" value="Refine Search" id="search_button" class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only ui-state-focus"/>
			</div>
		</form>
	</xsl:template>-->


</xsl:stylesheet>
