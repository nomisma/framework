<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" exclude-result-prefixes="#all" version="2.0">
	
	<!-- ********** VISUALIZATION TEMPLATES *********** -->
	<xsl:template name="distribution-form">
		<xsl:variable name="options" as="element()*">
			<options>
				<xsl:for-each select="$classes//class[@dist=true()][not(text()=$type)]">
					<xsl:choose>
						<xsl:when test="@prop = '?prop'">
							<!-- ignore foaf classes -->
							<xsl:if test="not($classes//class[text()=$type]/@prop = '?prop')">
								<xsl:for-each select="$classes/prop">
									<option value="{.}">
										<xsl:value-of select="substring-after(., 'has')"/>
									</option>
								</xsl:for-each>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<option value="{@prop}">
								<xsl:value-of select="substring-after(., ':')"/>
							</option>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</options>
		</xsl:variable>
		
		<div class="row" id="quant">
			<div class="col-md-12 page-section">
				<hr/>
				<h2>Quantitative Analysis</h2>
				<!-- display chart div when applicable, with additional filtering options -->
				<xsl:if test="string($dist) and string($filter)">
					<!--<xsl:variable name="distribution-query" select="replace(replace(unparsed-text('file:/usr/local/projects/nomisma/ui/sparql/typological_distribution.sparql','UTF-8'), '%FILTERS%', $filter), '%DIST%', $dist)"/>-->
					<div id="chart"/>
					<p>Result is limited to 100.</p>
					<!--<div style="margin-bottom:10px;" class="control-row">
								<a href="#" class="toggle-button btn btn-primary" id="toggle-quant"><span class="glyphicon glyphicon-plus"/> View SPARQL for full query</a>
								<a href="{$display_path}query?query={encode-for-uri($distribution-query)}&amp;output=csv" title="Download CSV" class="btn btn-primary" style="margin-left:10px">
									<span class="glyphicon glyphicon-download"/>Download CSV</a>
							</div>-->
					<!--<div id="quant-div" style="display:none">
								<pre>
									<xsl:value-of select="$distribution-query"/>
								</pre>
							</div>-->
				</xsl:if>
				
				<h3>Typological Distribution</h3>
				<form role="form" id="calculateForm" action="{$display_path}id/{$id}#quant" method="get">
					<div class="form-group">
						<h4>Category</h4>
						<p>Select a category below to generate a graph showing the quantitative distribution for this typology. The distribution is based on coin type data aggregated into Nomisma.</p>
						<select name="dist" class="form-control" id="categorySelect">
							<option value="">Select...</option>
							<xsl:for-each select="$options/option[not(preceding-sibling::option/text() = text())]">
								<xsl:sort select="." order="ascending"/>
								<option value="{@value}">
									<xsl:if test="@value = $dist">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="."/>
								</option>
							</xsl:for-each>
						</select>
						
						<input type="hidden" name="filter">
							<xsl:if test="string($filter)">
								<xsl:attribute name="class" select="$filter"/>
							</xsl:if>
						</input>
					</div>
					<div class="form-group">
						<h4>Numeric response type</h4>
						<input type="radio" name="type" value="percentage">
							<xsl:if test="not(string($numericType)) or $numericType = 'percentage'">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
							<xsl:text>Percentage</xsl:text>
						</input>
						<br/>
						<input type="radio" name="type" value="count">
							<xsl:if test="$numericType = 'count'">
								<xsl:attribute name="checked">checked</xsl:attribute>
							</xsl:if>
							<xsl:text>Count</xsl:text>
						</input>
					</div>
					<div class="form-inline">
						<h4>Additional Filters</h4>
						<p>Include additional filters to the basic distribution query for this concept. <a href="#" id="add-filter"><span class="glyphicon glyphicon-plus"/>Add one</a></p>
						<div id="filter-container">
							<!-- if there's a dist and filter, then break the filter query and insert preset filter templates -->
							<xsl:if test="$dist and $filter">
								<xsl:variable name="filterPieces" select="tokenize($filter, ';')"/>
								
								<xsl:for-each select="$filterPieces[not(normalize-space(.) = $base-query)]">
									<xsl:call-template name="field-template">
										<xsl:with-param name="query" select="normalize-space(.)"/>
									</xsl:call-template>
								</xsl:for-each>
							</xsl:if>
						</div>
					</div>
					<div class="form-inline">
						<h4>Compare to Other Queries</h4>
						<p>You can compare mutiple queries to generate a more complex chart depicting the distribution for the Category selected above. <a href="#" id="add-compare"><span
							class="glyphicon glyphicon-plus"/>Add query</a></p>
						<div id="compare-master-container">
							<xsl:for-each select="$compare">
								<xsl:call-template name="compare-container-template">
									<xsl:with-param name="template" as="xs:boolean">false</xsl:with-param>
									<xsl:with-param name="query" select="normalize-space(.)"/>
								</xsl:call-template>
							</xsl:for-each>
						</div>
						
						
					</div>
					
					<input type="submit" value="Generate" class="btn btn-default" id="visualize-submit" disabled="disabled"/>
				</form>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template name="compare-container-template">
		<xsl:param name="template"/>
		<xsl:param name="query"/>
		
		<div class="compare-container" style="padding-left:20px;margin-left:20px;border-left:1px solid gray">
			<xsl:if test="$template = true()">
				<xsl:attribute name="id">compare-container-template</xsl:attribute>
			</xsl:if>
			<h4>
				<xsl:text>Dataset</xsl:text>
				<small>
					<a href="#" title="Remove Dataset" class="remove-dataset">
						<span class="glyphicon glyphicon-remove"/>
					</a>
					<a href="#" class="add-compare-field" title="Add Query Field"><span class="glyphicon glyphicon-plus"/>Add Query Field</a>
				</small>
			</h4>
			<div class="bg-danger alert-box hidden">
				<span class="glyphicon glyphicon-exclamation-sign"></span>
				<strong>Alert:</strong> There must be at least one field in the dataset query.</div>
			<!-- if this xsl:template isn't an HTML template used by Javascript (generated in DOM from the compare request parameter), then pre-populate the query fields -->
			<xsl:if test="$template = false()">
				<xsl:for-each select="tokenize($query, ';')">
					<xsl:call-template name="field-template">
						<xsl:with-param name="template" as="xs:boolean">false</xsl:with-param>
						<xsl:with-param name="mode">compare</xsl:with-param>
						<xsl:with-param name="query" select="normalize-space(.)"/>
					</xsl:call-template>
				</xsl:for-each>
				
				
			</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template name="field-template">
		<xsl:param name="template"/>
		<xsl:param name="query"/>
		<xsl:param name="mode"/>
		
		<div class="form-group filter" style="display:block; margin-bottom:15px;">
			<xsl:if test="$template = true()">
				<xsl:attribute name="id">field-template</xsl:attribute>
			</xsl:if>
			<select class="form-control add-filter-prop">
				<xsl:call-template name="property-list">
					<xsl:with-param name="template" select="$template"/>
					<xsl:with-param name="query" select="$query"/>
					<xsl:with-param name="mode" select="$mode"/>
				</xsl:call-template>
			</select>
			
			<div class="prop-container">
				<xsl:if test="string($query)">
					<span class="hidden">
						<xsl:value-of select="$query"/>
					</span>
				</xsl:if>
			</div>
			
			<div class="control-container">
				<span class="glyphicon glyphicon-exclamation-sign hidden" title="A selection is required"/>
				<a href="#" title="Remove Property-Object Pair" class="remove-query">
					<span class="glyphicon glyphicon-remove"/>
				</a>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template name="ajax-loader-template">
		<span id="ajax-loader-template"><img src="{$display_path}ui/images/ajax-loader.gif" alt="loading"/> Loading</span>
	</xsl:template>
	
	<xsl:template name="property-list">
		<xsl:param name="query"/>
		<xsl:param name="mode"/>
		<xsl:param name="template"/>
		
		<xsl:variable name="properties" as="element()*">
			<properties>
				<prop value="nmo:hasAuthority" class="foaf:Person|foaf:Organization">Authority</prop>
				<prop value="nmo:hasIssuer" class="foaf:Person|foaf:Organization">Issuer</prop>
				<prop value="nmo:hasMaterial" class="nmo:Material">Material</prop>
				<prop value="nmo:hasMint" class="nmo:Mint">Mint</prop>
			</properties>
		</xsl:variable>
		
		<option>Select...</option>
		<xsl:choose>
			<xsl:when test="$mode = 'compare' or $template = true()">
				<xsl:apply-templates select="$properties//prop">
					<xsl:with-param name="query" select="$query"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$properties//prop[not(contains(@class, $type))]">
					<xsl:with-param name="query" select="$query"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="prop">
		<xsl:param name="query"/>
		<xsl:variable name="value" select="@value"/>
		
		<option value="{$value}" type="{@class}">
			<xsl:if test="substring-before($query, ' ') = $value">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="."/>
		</option>
	</xsl:template>
	
</xsl:stylesheet>