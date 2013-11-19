<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml" xmlns:res="http://www.w3.org/2005/sparql-results#"
	exclude-result-prefixes="xs res" version="2.0">
	<xsl:include href="templates.xsl"/>

	<!-- request params -->
	<xsl:param name="q"/>
	<xsl:param name="rows">100</xsl:param>
	<xsl:param name="sort"/>
	<xsl:param name="start"/>

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



	<xsl:template match="/">
		<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml"
			prefix="nm: http://nomisma.org/id/
			dcterms: http://purl.org/dc/terms/
			foaf: http://xmlns.com/foaf/0.1/
			geo:  http://www.w3.org/2003/01/geo/wgs84_pos#
			owl:  http://www.w3.org/2002/07/owl#
			rdfs: http://www.w3.org/2000/01/rdf-schema#
			rdfa: http://www.w3.org/ns/rdfa#
			rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
			skos: http://www.w3.org/2004/02/skos/core#"
			vocab="http://nomisma.org/id/">
			<head>
				<link rel="alternate" type="application/atom+xml" href="feed/{if ($q = '*:*') then '' else concat('?q=', $q)}"/>
				<!-- opensearch compliance -->
				<link rel="search" type="application/opensearchdescription+xml" href="http://nomisma.org/opensearch.xml" title="Example Search for http://nomisma.org/"/>
				<meta name="totalResults" content="{$numFound}"/>
				<meta name="startIndex" content="{$start_var}"/>
				<meta name="itemsPerPage" content="{$rows}"/>
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/>
				<title>Nomisma: all ids</title>
				<style type="text/css">
					@import url(<xsl:value-of select="concat($display_path, 'style.css')"/>
					);</style>
				<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"/>
			</head>
			<body>
				<!-- header -->
				<xsl:call-template name="header"/>

				<div class="center">
					<xsl:call-template name="filter"/>
					<h2>Results</h2>
					<xsl:call-template name="paging"/>
					<xsl:apply-templates select="descendant::doc[string(str[@name='id'])]"/>
				</div>

				<!-- footer -->
				<xsl:call-template name="footer"/>

			</body>
		</html>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="style" select="if(position() mod 2 = 0) then 'even-row' else 'odd-row'"/>
		<div class="result-doc {$style}">
			<span class="doc-label">
				<a href="{str[@name='id']}" title="{if(string(str[@name='prefLabel'])) then str[@name='prefLabel'] else str[@name='id']}">
					<xsl:value-of select="if(string(str[@name='prefLabel'])) then str[@name='prefLabel'] else str[@name='id']"/>
				</a>
			</span>
			<xsl:if test="string(str[@name='definition']) or not(contains($q, 'typeof'))">
				<dl>
					<xsl:if test="string(str[@name='definition'])">
						<dt>Definition</dt>
						<dd>
							<xsl:value-of select="str[@name='definition']"/>
						</dd>
					</xsl:if>
					<xsl:if test="not(contains($q, 'typeof'))">
						<dt>Type</dt>
						<dd>
							<xsl:for-each select="arr[@name='typeof']/str">
								<a href="{.}">
									<xsl:value-of select="."/>
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
		<xsl:variable name="query">
			<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>
			PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
			SELECT ?uri ?label WHERE {
			?uri  rdf:type <http://nomisma.org/id/numismatic_term>.
			?uri skos:prefLabel ?label .
			FILTER (lang(?label) = "en")}
			ORDER BY ASC(?label)
			]]>
		</xsl:variable>
		<xsl:variable name="service" select="concat('http://nomisma.org/query?query=', encode-for-uri(normalize-space($query)), '&amp;output=xml')"/>

		<form action="." class="filter-form">
			<span><b>Filter: </b></span>
			<select name="q">
				<option value="">Select...</option>
				<xsl:for-each select="document($service)//res:result">
					<xsl:variable name="value" select="concat('typeof:', substring-after(res:binding[@name='uri']/res:uri, 'id/'))"/>
					<option value="{$value}">
						<xsl:if test="$q = $value">
							<xsl:attribute name="selected">selected</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="res:binding[@name='label']/res:literal"/>
					</option>
				</xsl:for-each>
			</select>
			<button>Submit</button>			
		</form>
		<xsl:if test="contains($q, 'typeof')">
			<form action="../id/" class="filter-form">
				<button>Clear</button>
			</form>
		</xsl:if>		
	</xsl:template>

	<xsl:template name="paging">
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

		<div class="paging_div">
			<div style="float:left;">
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
			<div style="float:right;">
				<ul class="paging">
					<xsl:choose>
						<xsl:when test="$start_var &gt;= $rows">
							<li>
								<a class="pagingBtn" href="?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">«</a>
							</li>

						</xsl:when>
						<xsl:otherwise>
							<li>«</li>
						</xsl:otherwise>
					</xsl:choose>

					<!-- always display links to the first two pages -->
					<xsl:if test="$start_var div $rows &gt;= 3">
						<li>
							<a class="pagingBtn" href="?q={encode-for-uri($q)}&amp;start=0{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
								<xsl:text>1</xsl:text>
							</a>
						</li>

					</xsl:if>
					<xsl:if test="$start_var div $rows &gt;= 4">
						<li>
							<a class="pagingBtn" href="?q={encode-for-uri($q)}&amp;start={$rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
								<xsl:text>2</xsl:text>
							</a>
						</li>

					</xsl:if>

					<!-- display only if you are on page 6 or greater -->
					<xsl:if test="$start_var div $rows &gt;= 5">
						<li>...</li>
					</xsl:if>

					<!-- always display links to the previous two pages -->
					<xsl:if test="$start_var div $rows &gt;= 2">
						<li>
							<a class="pagingBtn" href="?q={encode-for-uri($q)}&amp;start={$start_var - ($rows * 2)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
								<xsl:value-of select="($start_var div $rows) -1"/>
							</a>
						</li>
					</xsl:if>
					<xsl:if test="$start_var div $rows &gt;= 1">
						<li>
							<a class="pagingBtn" href="?q={encode-for-uri($q)}&amp;start={$start_var - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
								<xsl:value-of select="$start_var div $rows"/>
							</a>
						</li>
					</xsl:if>

					<li>
						<b>
							<xsl:value-of select="$current"/>
						</b>
					</li>

					<!-- next two pages -->
					<xsl:if test="($start_var div $rows) + 1 &lt; $total">
						<li>
							<a class="pagingBtn" href="?q={encode-for-uri($q)}&amp;start={$start_var + $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
								<xsl:value-of select="($start_var div $rows) +2"/>
							</a>
						</li>
					</xsl:if>
					<xsl:if test="($start_var div $rows) + 2 &lt; $total">
						<li>
							<a class="pagingBtn" href="?q={encode-for-uri($q)}&amp;start={$start_var + ($rows * 2)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
								<xsl:value-of select="($start_var div $rows) +3"/>
							</a>
						</li>
					</xsl:if>
					<xsl:if test="$start_var div $rows &lt;= $total - 6">
						<li>...</li>
					</xsl:if>

					<!-- last two pages -->
					<xsl:if test="$start_var div $rows &lt;= $total - 5">
						<li>
							<a class="pagingBtn" href="?q={encode-for-uri($q)}&amp;start={($total * $rows) - ($rows * 2)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
								<xsl:value-of select="$total - 1"/>
							</a>
						</li>
					</xsl:if>
					<xsl:if test="$start_var div $rows &lt;= $total - 4">
						<li>
							<a class="pagingBtn" href="?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
								<xsl:value-of select="$total"/>
							</a>
						</li>
					</xsl:if>

					<xsl:choose>
						<xsl:when test="$numFound - $start_var &gt; $rows">
							<li>
								<a class="pagingBtn" href="?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">»</a>
							</li>
						</xsl:when>
						<xsl:otherwise>
							<li>»</li>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
