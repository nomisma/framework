<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>
	<xsl:include href="../vis-templates.xsl"/>

	<!-- request params -->	
	<!-- distribution params -->
	<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name = 'dist']/value"/>
	<xsl:param name="numericType" select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>
	<!-- query params -->
	<xsl:param name="compare" select="doc('input:request')/request/parameters/parameter[name = 'compare']/value"/>
	<xsl:param name="filter" select="doc('input:request')/request/parameters/parameter[name = 'filter']/value"/>
	<!-- metrical analysis params -->
	<xsl:param name="measurement" select="doc('input:request')/request/parameters/parameter[name = 'measurement']/value"/>	
	<xsl:param name="from" select="doc('input:request')/request/parameters/parameter[name = 'from']/value"/>
	<xsl:param name="to" select="doc('input:request')/request/parameters/parameter[name = 'to']/value"/>
	<xsl:param name="interval" select="doc('input:request')/request/parameters/parameter[name = 'interval']/value"/>
	<xsl:param name="analysisType" select="doc('input:request')/request/parameters/parameter[name='analysisType']/value"/>
	
	<!-- interface -->
	<xsl:param name="interface" select="tokenize(doc('input:request')/request/request-uri, '/')[last()]"/>	

	<!-- empty variables to account for vis templates -->
	<xsl:variable name="base-query"/>
	<xsl:variable name="id"/>
	<xsl:variable name="type"/>
	<xsl:variable name="classes" as="item()*">
		<classes/>
	</xsl:variable>

	<!-- config or other variables -->
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="mode">page</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>
					<xsl:text>nomisma.org: </xsl:text>
					<xsl:choose>
						<xsl:when test="$interface = 'distribution'">Typological Distribution</xsl:when>
						<xsl:when test="$interface = 'metrical'">Metrical Analysis</xsl:when>
					</xsl:choose>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="http://code.jquery.com/jquery-2.1.4.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
				<script type="text/javascript" src="https://d3plus.org/js/d3.js"/>
				<script type="text/javascript" src="https://d3plus.org/js/d3plus.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/vis_functions.js"/>
				
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
					<h2>Quantitative Analysis</h2>			
					<xsl:choose>
						<xsl:when test="$interface = 'distribution'">
							<xsl:call-template name="distribution-form">
								<xsl:with-param name="mode" select="$mode"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$interface = 'metrical'">
							<xsl:call-template name="metrical-form">
								<xsl:with-param name="mode" select="$mode"/>
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
					
				</div>
			</div>
		
		</div>

		<!-- variables retrieved from the config and used in javascript -->
		<div class="hidden">			
			<span id="path">
				<xsl:value-of select="$display_path"/>
			</span>
			<span id="page">
				<xsl:value-of select="$mode"/>
			</span>
			<span id="interface">
				<xsl:value-of select="$interface"/>
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
