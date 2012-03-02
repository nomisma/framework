<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="header-public.xsl"/>
	<xsl:include href="footer-public.xsl"/>
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'nomisma/config.xml'))"/>
	<xsl:variable name="display_path">./</xsl:variable>
	<xsl:variable name="pipeline">index</xsl:variable>

	<xsl:template match="/">
		<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
				<title>nomisma.org</title>
				<!-- styling -->
				<link rel="stylesheet" type="text/css" href="{$display_path}css/grids-min.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}css/reset-fonts-grids.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}css/base-min.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}css/fonts-min.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}css/jquery-ui-1.8.12.custom.css"/>

				<!-- nomisma styling -->
				<link rel="stylesheet" href="{$display_path}css/style.css"/>

				<!-- javascript -->
				<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
				<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
				<script type="text/javascript" src="{$display_path}/javascript/jquery-1.6.1.min.js"/>
				<script type="text/javascript" src="{$display_path}/javascript/menu.js"/>
				<script type="text/javascript" src="{$display_path}/javascript/index_map_functions.js"/>
				<script type="text/javascript">
					$(document).ready(function(){
						initialize_map('typeof:mint');
					});
				</script>
			</head>
			<body class="yui-skin-sam">
				<div id="doc4" class="yui-t4">
					<xsl:call-template name="header-public"/>
					<div id="bd">
						<div id="yui-main">
							<div class="yui-b">
								<xsl:call-template name="indexContent"/>
								<h3>Map of Mints</h3>
								<div id="indexMap"/>
							</div>
						</div>
						<div class="yui-b">
							<div id="lod">
								<h3>Data Options</h3>
								<span class="option">
									<a href="{$display_path}feed/?q=*:*">
										<img src="{$display_path}images/atom-large.png" alt="Atom"/>
									</a>
								</span>
							</div>
						</div>

					</div>
					<xsl:call-template name="footer-public"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="indexContent">
		<h3>
			<a name="Introduction" id="Introduction">Introduction</a>
		</h3>
		<div class="level3">
			<p> Nomisma.org is a collaborative effort to provide stable digital representations of numismatic concepts and entities, for example the generic idea of a coin hoard or an actual hoard as
				documented in the print publication <em>An Inventory of Greek Coin Hoards</em> (IGCH). Nomisma.org provides a short, often recognizable, <acronym title="Uniform Resource Identifier"
					>URI</acronym> for each resource it defines and presents the related information in both human and machine readable form. Creators of digital content can use these stable URIs to
				build a web of linked knowledge that enables faster acquisition and analysis of well-structured numismatic data. </p>
		</div>
	</xsl:template>
</xsl:stylesheet>
