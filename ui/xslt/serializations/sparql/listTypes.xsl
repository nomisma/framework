<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: June 2025
	Function: serialize SPARQL results for coin types associated with the given Nomisma concept into HTML. Call the numishareResults API to display related images 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../../controllers/metamodel-templates.xsl"/>
	<xsl:include href="../../controllers/sparql-metamodel.xsl"/>

	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name = 'query']/value"/>
	<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name = 'id']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>
	<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name = 'sort']/value"/>
	<xsl:param name="page" as="xs:integer">
		<xsl:choose>
			<xsl:when
				test="
					string-length(doc('input:request')/request/parameters/parameter[name = 'page']/value) &gt; 0 and doc('input:request')/request/parameters/parameter[name = 'page']/value castable
					as xs:integer and number(doc('input:request')/request/parameters/parameter[name = 'page']/value) > 0">
				<xsl:value-of select="doc('input:request')/request/parameters/parameter[name = 'page']/value"/>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="string($query)"/>
			<xsl:otherwise>../</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="query" select="doc('input:query')"/>

	<xsl:variable name="limit" select="10"/>
	<xsl:variable name="numFound" select="doc('input:typeCount')/descendant::res:binding[@name = 'count']/res:literal" as="xs:integer"/>


	<xsl:template match="/">
		<xsl:apply-templates select="/res:sparql"/>
	</xsl:template>

	<xsl:template match="res:sparql[count(descendant::res:result) &gt; 0]">
		<!-- aggregate ids and get URI space -->
		<xsl:variable name="type_series_items" as="element()*">
			<type_series_items>
				<xsl:for-each select="descendant::res:result/res:binding[@name = 'coinType']/res:uri">
					<item>
						<xsl:value-of select="."/>
					</item>
				</xsl:for-each>
			</type_series_items>
		</xsl:variable>
		
		

		<!-- use the Numishare Results API to display example coins -->
		<xsl:variable name="sparqlResult" as="element()*">
			<xsl:variable name="ids" select="string-join($type_series_items//item, '|')"/>
			
			<response>
				<xsl:variable name="service"
					select="concat('http://localhost:8080/orbeon/nomisma/apis/numishareResults?identifiers=', encode-for-uri($ids))"/>
				<xsl:copy-of select="document($service)/response/*"/>
			</response>
		</xsl:variable>

		<!-- dynamically generate SPARQL query based on the template, given the $type and $id -->
		<xsl:variable name="statements" as="element()*">
			<xsl:call-template name="nomisma:listTypesStatements">
				<xsl:with-param name="q" select="$q"/>
				<xsl:with-param name="type" select="$type"/>
				<xsl:with-param name="id" select="$id"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="statementsSPARQL">
			<xsl:apply-templates select="$statements/*"/>
		</xsl:variable>

		<!-- HTML output -->
		<h3>
			<xsl:text>Associated Types </xsl:text>
			<small>
				<a href="#" class="toggle-button" id="toggle-ajaxList" title="Click to hide or show the analysis form">
					<span class="glyphicon glyphicon-triangle-bottom"/>
				</a>
			</small>
		</h3>

		<xsl:if test="$numFound &gt; $limit">
			<xsl:call-template name="pagination">
				<xsl:with-param name="page" select="$page" as="xs:integer"/>
				<xsl:with-param name="numFound" select="$numFound" as="xs:integer"/>
				<xsl:with-param name="limit" select="$limit" as="xs:integer"/>
			</xsl:call-template>
		</xsl:if>

		<div id="ajaxList-div">
			<div style="margin-bottom:10px;" class="control-row">
				<a href="#" class="toggle-button btn btn-primary" id="toggle-ajaxListQuery"><span class="glyphicon glyphicon-plus"/> View SPARQL for full
					query</a>
				<a href="{$display_path}query?query={encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL))}&amp;output=csv" title="Download CSV"
					class="btn btn-primary" style="margin-left:10px">
					<span class="glyphicon glyphicon-download"/>Download CSV</a>
			</div>
			<div id="ajaxListQuery-div" style="display:none">
				<pre>
				<xsl:value-of select="replace($query, '%STATEMENTS%', $statementsSPARQL)"/>
			</pre>
			</div>

			<table class="table table-striped table-responsive">
				<thead>
					<tr>
						<th>Type</th>
						<th>
							<xsl:text>Authority</xsl:text>
							<xsl:choose>
								<xsl:when test="$sort = '(!bound(?authorityLabels)) ASC(?authorityLabels)'">
									<a class="sort-types" href="?sort={encode-for-uri('(!bound(?authorityLabels)) DESC(?authorityLabels)')}{if (string($q)) then concat('&amp;query=', $q) else ''}">
										<span class="glyphicon glyphicon-sort-by-alphabet-alt"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a class="sort-types" href="?sort={encode-for-uri('(!bound(?authorityLabels)) ASC(?authorityLabels)')}{if (string($q)) then concat('&amp;query=', $q) else ''}">
										<span class="glyphicon glyphicon-sort-by-alphabet"/>
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</th>
						<th>
							<xsl:text>Mint</xsl:text>
							<xsl:choose>
								<xsl:when test="$sort = '(!bound(?mintLabels)) ASC(?mintLabels)'">
									<a class="sort-types" href="?sort={encode-for-uri('(!bound(?mintLabels)) DESC(?mintLabels)')}{if (string($q)) then concat('&amp;query=', $q) else ''}">
										<span class="glyphicon glyphicon-sort-by-alphabet-alt"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a class="sort-types" href="?sort={encode-for-uri('(!bound(?mintLabels)) ASC(?mintLabels)')}{if (string($q)) then concat('&amp;query=', $q) else ''}">
										<span class="glyphicon glyphicon-sort-by-alphabet"/>
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</th>
						<th>
							<xsl:text>Denomination</xsl:text>
							<xsl:choose>
								<xsl:when test="$sort = '(!bound(?denLabels)) ASC(?denLabels)'">
									<a class="sort-types" href="?sort={encode-for-uri('(!bound(?denLabels)) DESC(?denLabels)')}{if (string($q)) then concat('&amp;query=', $q) else ''}">
										<span class="glyphicon glyphicon-sort-by-alphabet-alt"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a class="sort-types" href="?sort={encode-for-uri('(!bound(?denLabels)) ASC(?denLabels)')}{if (string($q)) then concat('&amp;query=', $q) else ''}">
										<span class="glyphicon glyphicon-sort-by-alphabet"/>
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</th>
						<th>
							<xsl:text>Date</xsl:text>
							<xsl:choose>
								<xsl:when test="$sort = '(!bound(?startDate)) ASC(?startDate)' or not(string($sort))">
									<a class="sort-types" href="?sort={encode-for-uri('(!bound(?startDate)) DESC(?startDate)')}{if (string($q)) then concat('&amp;query=', $q) else ''}">
										<span class="glyphicon glyphicon-sort-by-order-alt"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a class="sort-types" href="?sort={encode-for-uri('(!bound(?startDate)) ASC(?startDate)')}{if (string($q)) then concat('&amp;query=', $q) else ''}">
										<span class="glyphicon glyphicon-sort-by-order"/>
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</th>
						<th style="width:280px">Example</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="descendant::res:result">
						<xsl:variable name="type_uri" select="res:binding[@name = 'coinType']/res:uri"/>

						<tr>
							<td>
								<a href="{res:binding[@name='coinType']/res:uri}">
									<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
								</a>
							</td>
							<td>
								<xsl:if test="res:binding[@name = 'authorities']/res:literal">
									<xsl:variable name="authorityLabels" select="res:binding[@name='authorityLabels']/res:literal"/>
									
									<xsl:for-each select="tokenize(res:binding[@name = 'authorities']/res:literal, '\|')">
										<xsl:variable name="position" select="position()"/>
										
										<a href="{.}">
											<xsl:value-of select="tokenize($authorityLabels, '\|')[$position]"/>
										</a>
										<xsl:if test="not(position() = last())">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:if>
							</td>
							<td>
								<xsl:if test="res:binding[@name = 'mints']/res:literal">
									<xsl:variable name="mintLabels" select="res:binding[@name='mintLabels']/res:literal"/>
									
									<xsl:for-each select="tokenize(res:binding[@name = 'mints']/res:literal, '\|')">
										<xsl:variable name="position" select="position()"/>
										
										<a href="{.}">
											<xsl:value-of select="tokenize($mintLabels, '\|')[$position]"/>
										</a>
										<xsl:if test="not(position() = last())">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:if>
							</td>
							<td>
								<xsl:if test="res:binding[@name = 'dens']/res:literal">
									<xsl:variable name="denLabels" select="res:binding[@name='denLabels']/res:literal"/>
									
									<xsl:for-each select="tokenize(res:binding[@name = 'dens']/res:literal, '\|')">
										<xsl:variable name="position" select="position()"/>
										
										<a href="{.}">
											<xsl:value-of select="tokenize($denLabels, '\|')[$position]"/>
										</a>
										<xsl:if test="not(position() = last())">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:if>
							</td>
							<td>
								<xsl:if test="res:binding[@name = 'startDate']/res:literal or res:binding[@name = 'endDate']/res:literal">
									<xsl:value-of select="nomisma:normalizeDate(res:binding[@name = 'startDate']/res:literal)"/>
									<xsl:if test="res:binding[@name = 'startDate']/res:literal and res:binding[@name = 'startDate']/res:literal">
										<xsl:text>–</xsl:text>
									</xsl:if>
									<xsl:value-of select="nomisma:normalizeDate(res:binding[@name = 'endDate']/res:literal)"/>
								</xsl:if>
							</td>
							<td class="text-right">
								<xsl:apply-templates select="$sparqlResult//group[@id = $type_uri]/descendant::object" mode="results"/>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</div>
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
					<img src="{obvThumb}" class="side-thumbnail"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(obvRef)) and string(obvThumb)">
				<img src="{obvThumb}" class="side-thumbnail">
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
					<img src="{obvRef}" class="side-thumbnail"/>
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
					<img src="{revThumb}" class="side-thumbnail"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(revRef)) and string(revThumb)">
				<img src="{revThumb}" class="side-thumbnail">
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
					<img src="{revRef}" class="side-thumbnail"/>
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
					<img src="{comThumb}" class="combined-thumbnail"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(comRef)) and string(comThumb)">
				<img src="{comThumb}" class="combined-thumbnail">
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
					<img src="{comRef}" class="combined-thumbnail"/>
				</a>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="pagination">
		<xsl:param name="page" as="xs:integer"/>
		<xsl:param name="numFound" as="xs:integer"/>
		<xsl:param name="limit" as="xs:integer"/>

		<xsl:variable name="offset" select="($page - 1) * $limit" as="xs:integer"/>

		<xsl:variable name="previous" select="$page - 1"/>
		<xsl:variable name="current" select="$page"/>
		<xsl:variable name="next" select="$page + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $limit)"/>

		<div class="col-md-12 paging_div">
			<div class="col-md-6">
				<xsl:variable name="startRecord" select="$offset + 1"/>
				<xsl:variable name="endRecord">
					<xsl:choose>
						<xsl:when test="$numFound &gt; ($offset + $limit)">
							<xsl:value-of select="$offset + $limit"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$numFound"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<p>Records <b><xsl:value-of select="$startRecord"/></b> to <b><xsl:value-of select="$endRecord"/></b> of <b><xsl:value-of select="$numFound"
						/></b></p>
			</div>
			<!-- paging functionality -->
			<div class="col-md-6 page-nos">
				<div class="btn-toolbar" role="toolbar">
					<div class="btn-group pull-right">
						<!-- first page -->
						<xsl:if test="$current &gt; 1">
							<a class="btn btn-default" role="button" title="First" href="?page=1{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($q)) then concat('&amp;query=', $q) else ''}">
								<span class="glyphicon glyphicon-fast-backward"/>
								<xsl:text> 1</xsl:text>
							</a>
							<a class="btn btn-default" role="button" title="Previous"
								href="?page={$current - 1}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($q)) then concat('&amp;query=', $q) else ''}">
								<xsl:text>Previous </xsl:text>
								<span class="glyphicon glyphicon-backward"/>
							</a>
						</xsl:if>
						<xsl:if test="$current &gt; 5">
							<button type="button" class="btn btn-default disabled">
								<xsl:text>...</xsl:text>
							</button>
						</xsl:if>
						<xsl:if test="$current &gt; 4">
							<a class="btn btn-default" role="button" href="?page={$current - 3}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($q)) then concat('&amp;query=', $q) else ''}">
								<xsl:value-of select="$current - 3"/>
								<xsl:text> </xsl:text>
							</a>
						</xsl:if>
						<xsl:if test="$current &gt; 3">
							<a class="btn btn-default" role="button" href="?page={$current - 2}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($q)) then concat('&amp;query=', $q) else ''}">
								<xsl:value-of select="$current - 2"/>
								<xsl:text> </xsl:text>
							</a>
						</xsl:if>
						<xsl:if test="$current &gt; 2">
							<a class="btn btn-default" role="button" href="?page={$current - 1}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($q)) then concat('&amp;query=', $q) else ''}">
								<xsl:value-of select="$current - 1"/>
								<xsl:text> </xsl:text>
							</a>
						</xsl:if>
						<!-- current page -->
						<button type="button" class="btn btn-default active">
							<b>
								<xsl:value-of select="$current"/>
							</b>
						</button>
						<xsl:if test="$total &gt; ($current + 1)">
							<a class="btn btn-default" role="button" title="Next"
								href="?page={$current + 1}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($q)) then concat('&amp;query=', $q) else ''}">
								<xsl:value-of select="$current + 1"/>
							</a>
						</xsl:if>
						<xsl:if test="$total &gt; ($current + 2)">
							<a class="btn btn-default" role="button" title="Next"
								href="?page={$current + 2}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($q)) then concat('&amp;query=', $q) else ''}">
								<xsl:value-of select="$current + 2"/>
							</a>
						</xsl:if>
						<xsl:if test="$total &gt; ($current + 3)">
							<a class="btn btn-default" role="button" title="Next"
								href="?page={$current + 3}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($q)) then concat('&amp;query=', $q) else ''}">
								<xsl:value-of select="$current + 3"/>
							</a>
						</xsl:if>
						<xsl:if test="$total &gt; ($current + 4)">
							<button type="button" class="btn btn-default disabled">
								<xsl:text>...</xsl:text>
							</button>
						</xsl:if>
						<!-- last page -->
						<xsl:if test="$current &lt; $total">
							<a class="btn btn-default" role="button" title="Next"
								href="?page={$current + 1}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($q)) then concat('&amp;query=', $q) else ''}">
								<xsl:text>Next </xsl:text>
								<span class="glyphicon glyphicon-forward"/>
							</a>
							<a class="btn btn-default" role="button" title="Last"
								href="?page={$total}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}{if (string($q)) then concat('&amp;query=', $q) else ''}">
								<xsl:value-of select="$total"/>
								<xsl:text> </xsl:text>
								<span class="glyphicon glyphicon-fast-forward"/>
							</a>
						</xsl:if>
					</div>
				</div>
			</div>

		</div>

	</xsl:template>
</xsl:stylesheet>
