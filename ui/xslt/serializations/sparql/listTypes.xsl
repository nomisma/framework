<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: June 2019
	Function: serialize SPARQL results for coin types associated with the given Nomisma concept into HTML. Call the numishareResults API to display related images 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../../controllers/metamodel-templates.xsl"/>
	<xsl:include href="../../controllers/sparql-metamodel.xsl"/>

	<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name = 'id']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>

	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="query" select="doc('input:query')"/>

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

		<xsl:variable name="type_series" as="element()*">
			<list>
				<xsl:for-each select="distinct-values(descendant::res:result/res:binding[@name = 'coinType']/substring-before(res:uri, 'id/'))">
					<xsl:variable name="uri" select="."/>
					<type_series uri="{$uri}">
						<xsl:for-each select="$type_series_items//item[starts-with(., $uri)]">
							<item>
								<xsl:value-of select="substring-after(., 'id/')"/>
							</item>
						</xsl:for-each>
					</type_series>
				</xsl:for-each>
			</list>
		</xsl:variable>

		<!-- use the Numishare Results API to display example coins -->
		<xsl:variable name="sparqlResult" as="element()*">
			<response>
				<xsl:for-each select="$type_series//type_series">
					<xsl:variable name="baseUri" select="concat(@uri, 'id/')"/>
					<xsl:variable name="ids" select="string-join(item, '|')"/>

					<xsl:variable name="service"
						select="concat('http://localhost:8080/orbeon/nomisma/apis/numishareResults?identifiers=', encode-for-uri($ids), '&amp;baseUri=',
						encode-for-uri($baseUri))"/>
					<xsl:copy-of select="document($service)/response/*"/>
				</xsl:for-each>
			</response>
		</xsl:variable>

		<!-- dynamically generate SPARQL query based on the template, given the $type and $id -->
		<xsl:variable name="statements" as="element()*">
			<xsl:call-template name="nomisma:listTypesStatements">
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
			<small>(max 10)</small>
			<small>
				<a href="#" class="toggle-button" id="toggle-listTypes" title="Click to hide or show the analysis form">
					<span class="glyphicon glyphicon-triangle-bottom"/>
				</a>
			</small>
		</h3>

		<div id="listTypes-div">
			<div style="margin-bottom:10px;" class="control-row">
				<a href="#" class="toggle-button btn btn-primary" id="toggle-listTypesQuery"><span class="glyphicon glyphicon-plus"/> View SPARQL for full
					query</a>
				<a href="{$display_path}query?query={encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL))}&amp;output=csv" title="Download CSV"
					class="btn btn-primary" style="margin-left:10px">
					<span class="glyphicon glyphicon-download"/>Download CSV</a>
			</div>
			<div id="listTypesQuery-div" style="display:none">
				<pre>
				<xsl:value-of select="replace($query, '%STATEMENTS%', $statementsSPARQL)"/>
			</pre>
			</div>

			<table class="table table-striped">
				<thead>
					<tr>
						<th>Type</th>
						<th>Type Series</th>
						<th style="width:280px">Example</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="descendant::res:result">
						<xsl:variable name="type_id" select="substring-after(res:binding[@name = 'coinType']/res:uri, 'id/')"/>

						<tr>
							<td>
								<a href="{res:binding[@name='coinType']/res:uri}">
									<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
								</a>
								<dl class="dl-horizontal">
									<xsl:if test="res:binding[@name = 'authority']/res:uri">
										<dt>Authority</dt>
										<dd>
											<a href="{res:binding[@name='authority']/res:uri}">
												<xsl:value-of select="res:binding[@name = 'authorityLabel']/res:literal"/>
											</a>
										</dd>
									</xsl:if>
									<xsl:if test="res:binding[@name = 'mint']/res:uri">
										<dt>Mint</dt>
										<dd>
											<a href="{res:binding[@name='mint']/res:uri}">
												<xsl:value-of select="res:binding[@name = 'mintLabel']/res:literal"/>
											</a>
										</dd>
									</xsl:if>
									<xsl:if test="res:binding[@name = 'den']/res:uri">
										<dt>Denomination</dt>
										<dd>
											<a href="{res:binding[@name='den']/res:uri}">
												<xsl:value-of select="res:binding[@name = 'denLabel']/res:literal"/>
											</a>
										</dd>
									</xsl:if>
									<xsl:if test="res:binding[@name = 'startDate']/res:literal or res:binding[@name = 'endDate']/res:literal">
										<dt>Date</dt>
										<dd>
											<xsl:value-of select="nomisma:normalizeDate(res:binding[@name = 'startDate']/res:literal)"/>
											<xsl:if test="res:binding[@name = 'startDate']/res:literal and res:binding[@name = 'startDate']/res:literal"> - </xsl:if>
											<xsl:value-of select="nomisma:normalizeDate(res:binding[@name = 'endDate']/res:literal)"/>
										</dd>
									</xsl:if>
								</dl>
							</td>
							<td>
								<a href="{res:binding[@name='source']/res:uri}">
									<xsl:value-of select="res:binding[@name = 'sourceLabel']/res:literal"/>
								</a>
							</td>
							<td class="text-right">
								<xsl:apply-templates select="$sparqlResult//group[@id = $type_id]/descendant::object" mode="results"/>
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
</xsl:stylesheet>
