<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../templates.xsl"/>

	<!-- empty variables to account for vis templates -->
	<xsl:variable name="base-query"/>
	<xsl:variable name="id"/>
	<xsl:variable name="type"/>
	<xsl:variable name="classes" as="item()*">
		<classes/>
	</xsl:variable>

	<xsl:param name="numericType" select="doc('input:request')/request/parameters/parameter[name = 'numericType']/value"/>

	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<xsl:param name="interface" select="tokenize(doc('input:request')/request/request-uri, '/')[last()]"/>

		<html lang="en">
			<head>
				<title>
					<xsl:text>nomisma.org: discover</xsl:text>
					<xsl:choose>
						<xsl:when test="$interface = 'distribution'">Typological Distribution</xsl:when>
						<xsl:when test="$interface = 'metrical'">Metrical Analysis</xsl:when>
					</xsl:choose>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.4.min.js"/>

				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>

				<!-- Add fancyBox -->
				<link rel="stylesheet" href="{$display_path}ui/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/jquery.fancybox.pack.js?v=2.1.5"/>

				<!-- leaflet and map functions -->
				<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
				<link rel="stylesheet" href="{$display_path}ui/css/leaflet.legend.css"/>
				<script type="text/javascript" src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/leaflet.ajax.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/leaflet.legend.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/leaflet-iiif.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/discovery_functions.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/facet_functions.js"/>

				<link rel="stylesheet" type="text/css" href="{$display_path}ui/css/style.css"/>

				<!-- google analytics -->
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
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
				<div class="col-md-12 page-section">
					<h2>Discover</h2>
					<div class="col-md-6">
						<p>Click on the <span class="glyphicon glyphicon-filter"/> icon to filter the map based on a query.</p>
					</div>
					<div class="col-md-6 text-right">
						
						<xsl:variable name="params" as="element()*">
							<params>
								<xsl:if test="string(doc('input:request')/request/parameters/parameter[name = 'query']/value)">
									<query>
										<xsl:value-of select="doc('input:request')/request/parameters/parameter[name = 'query']/value"/>
									</query>										
								</xsl:if>
								<xsl:if test="string($numericType)">
									<numericType>
										<xsl:value-of select="$numericType"/>
									</numericType>
								</xsl:if>
								<xsl:if test="string(doc('input:request')/request/parameters/parameter[name = 'type']/value)">
									<type>
										<xsl:value-of select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>
									</type>									
								</xsl:if>
								<xsl:for-each select="doc('input:request')/request/parameters/parameter[name = 'compare']">
									<compare>
										<xsl:value-of select="value"/>
									</compare>
								</xsl:for-each>
							</params>
						</xsl:variable>
						
						<xsl:variable name="paramString">
							<xsl:for-each select="$params/*">
								<xsl:value-of select="name()"/>
								<xsl:text>=</xsl:text>
								<xsl:value-of select="."/>
								<xsl:if test="not(position() = last())">
									<xsl:text>&amp;</xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						
						<p>
							<xsl:if test="not(string($paramString))">
								<xsl:attribute name="class">hidden</xsl:attribute>
							</xsl:if>							
							
							<a href="discover?{$paramString}" id="permalink"><span class="glyphicon glyphicon-link"/> Copy Link</a>
							<span style="display:none" id="permalink-tooltip"> copied</span>
						</p>
					</div>
					<div id="mapcontainer" class="map-discover"/>					
					<div id="ajaxList"/>
				</div>
			</div>

			<div style="display:none">
				<div id="map_filters">
					<form role="form" id="geoForm" class="quant-form" method="get">
						<h2>Filters</h2>
						<a href="#" class="add-compare hidden"><span class="glyphicon glyphicon-plus"/>Add query for Comparison</a>

						<div class="form-inline">
							<input type="radio" name="compareBy" value="all" checked="checked" style="margin-left:20px;">
								<xsl:text>View all mints, hoards, and findspots</xsl:text>
							</input>
							<input type="radio" name="compareBy" value="mint" style="margin-left:20px;">
								<xsl:text>Compare mints</xsl:text>
							</input>
							<input type="radio" name="compareBy" value="hoard" style="margin-left:20px;">
								<xsl:text>Compare hoards</xsl:text>
							</input>
							<input type="radio" name="compareBy" value="findspot" style="margin-left:20px;">
								<xsl:text>Compare findspots</xsl:text>
							</input>
						</div>
						<hr/>

						<div class="form-inline">
							<span>Group by number of:</span>
							<input type="radio" name="numericType" value="coinType" style="margin-left:20px;">
								<xsl:if test="not(string($numericType)) or $numericType = 'coinType'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
								<xsl:text>Coin Types</xsl:text>
							</input>
							<input type="radio" name="numericType" value="object" style="margin-left:20px;">
								<xsl:if test="$numericType = 'object'">
									<xsl:attribute name="checked">checked</xsl:attribute>
								</xsl:if>
								<xsl:text>Objects</xsl:text>
							</input>
						</div>
						<div class="form-inline">
							<div class="compare-master-container">
								<xsl:call-template name="compare-container-template">
									<xsl:with-param name="template" as="xs:boolean">false</xsl:with-param>
								</xsl:call-template>
							</div>
						</div>

						<input type="submit" value="Update Map" class="btn btn-default visualize-submit" disabled="disabled"/>

						<input type="button" class="btn btn-default" id="close" value="Close"/>
					</form>
				</div>
			</div>

		</div>

		<!-- variables retrieved from the config and used in javascript -->
		<div class="hidden">
			<span id="path">
				<xsl:value-of select="$display_path"/>
			</span>
			<span id="mapboxKey">
				<xsl:value-of select="//config/mapboxKey"/>
			</span>
			<span id="page">discover</span>
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
			
			<span id="numericType">
				<xsl:value-of select="$numericType"/>
			</span>

			<!-- IIIF -->
			<span id="manifest"/>
			<div class="iiif-container-template" style="width:100%;height:100%"/>
			<div id="iiif-window" style="width:600px;height:600px;display:none"/>

			<span id="legend">
				<xsl:text>[{"label": "Mint", "type": "rectangle", "fillColor": "#6992fd", "color": "black","weight": 1}, 
				{"label": "Hoard", "type": "rectangle", "fillColor": "#d86458", "color": "black", "weight": 1},
				{"label": "Findspot", "type":"rectangle", "fillColor": "#f98f0c", "color": "black", "weight": 1}]</xsl:text>
			</span>
		</div>
	</xsl:template>



	<!-- ******** TEMPLATES ********* -->
	<xsl:template name="compare-container-template">
		<xsl:param name="template"/>

		<div class="compare-container" style="padding-left:20px;margin-left:20px;border-left:1px solid gray">
			<xsl:if test="$template = true()">
				<xsl:attribute name="id">compare-container-template</xsl:attribute>
			</xsl:if>

			<h4>
				<xsl:text>Query Group</xsl:text>
				<small>
					<a href="#" title="Remove Group" class="remove-dataset hidden">
						<span class="glyphicon glyphicon-remove"/>
					</a>
					<a href="#" class="add-compare-field" title="Add Query Field"><span class="glyphicon glyphicon-plus"/>Add Query Field</a>
				</small>
			</h4>

			<div class="empty-query-alert alert alert-box alert-danger hidden">
				<span class="glyphicon glyphicon-exclamation-sign"/>
				<strong>Alert:</strong> There must be at least one field in the group query.</div>
			<div class="duplicate-date-alert alert alert-box alert-danger hidden">
				<span class="glyphicon glyphicon-exclamation-sign"/>
				<strong>Alert:</strong> There must not be more than one from or to date.</div>
			<!-- if this xsl:template isn't an HTML template used by Javascript (generated in DOM from the compare request parameter), then pre-populate the query fields -->

			<input type="color" value="#ff0000" name="color" class="hidden" disabled="disabled"/>

			<xsl:if test="$template = false()">
				<xsl:call-template name="field-template">
					<xsl:with-param name="template" as="xs:boolean">false</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="field-template">
		<xsl:param name="template"/>

		<div class="form-group filter" style="display:block; margin-bottom:15px;">
			<xsl:if test="$template = true()">
				<xsl:attribute name="id">field-template</xsl:attribute>
			</xsl:if>
			<select class="form-control add-filter-prop">
				<xsl:call-template name="property-list">
					<xsl:with-param name="template" select="$template"/>
				</xsl:call-template>
			</select>

			<div class="prop-container"> </div>

			<div class="control-container">
				<span class="glyphicon glyphicon-exclamation-sign hidden" title="A selection is required"/>
				<a href="#" title="Remove Property-Object Pair" class="remove-query">
					<span class="glyphicon glyphicon-remove"/>
				</a>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="date-template">
		<xsl:param name="template"/>

		<span>
			<xsl:if test="$template = true()">
				<xsl:attribute name="id">date-container-template</xsl:attribute>
			</xsl:if>

			<input type="number" class="form-control year" min="1" step="1" placeholder="Year"> </input>
			<select class="form-control era">
				<option value="bc">
					<xsl:text>BCE</xsl:text>
				</option>
				<option value="ad">
					<xsl:text>CE</xsl:text>
				</option>
			</select>
		</span>
	</xsl:template>

	<xsl:template name="ajax-loader-template">
		<span id="ajax-loader-template"><img src="{$display_path}ui/images/ajax-loader.gif" alt="loading"/> Loading</span>
	</xsl:template>

	<xsl:template name="property-list">
		<xsl:param name="template"/>

		<xsl:variable name="properties" as="element()*">
			<properties>
				<prop value="authPerson" class="foaf:Person">Authority (Person)</prop>
				<prop value="authCorp" class="foaf:Organization">Authority (State)</prop>
				<prop value="nmo:hasStatedAuthority" class="foaf:Person|foaf:Organization">Authority, Stated</prop>
				<prop value="?prop" class="foaf:Person|foaf:Organization">Authority, Issuer, or Portrait</prop>
				<prop value="from">Date, From</prop>
				<prop value="to">Date, To</prop>
				<prop value="nmo:hasDenomination" class="nmo:Denomination">Denomination</prop>
				<prop value="deity" class="">Deity</prop>
				<prop value="dynasty" class="">Dynasty</prop>
				<prop value="fon" class="nmo:FieldOfNumismatics">Field of Numismatics</prop>
				<prop value="nmo:hasIssuer" class="foaf:Person|foaf:Organization">Issuer</prop>
				<prop value="nmo:hasManufacture" class="nmo:Manufacture">Manufacture</prop>
				<prop value="nmo:hasMaterial" class="nmo:Material">Material</prop>
				<prop value="nmo:hasMint" class="nmo:Mint">Mint</prop>
				<prop value="nmo:representsObjectType" class="nmo:ObjectType">ObjectType</prop>
				<prop value="portrait" class="">Portrait</prop>
				<prop value="nmo:hasRegion" class="nmo:Region">Region</prop>
			</properties>
		</xsl:variable>

		<option>Select...</option>
		<xsl:apply-templates select="$properties//prop"/>
	</xsl:template>

	<xsl:template match="prop">
		<xsl:variable name="value" select="@value"/>

		<option value="{$value}" type="{@class}">
			<xsl:value-of select="."/>
		</option>
	</xsl:template>

	<xsl:template name="toggle-button">
		<xsl:param name="form"/>

		<small>
			<a href="#" class="toggle-button" id="toggle-{$form}" title="Click to hide or show the analysis form">
				<span class="glyphicon glyphicon-triangle-right"/>
			</a>
		</small>
	</xsl:template>

</xsl:stylesheet>
