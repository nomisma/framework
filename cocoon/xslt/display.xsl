<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" xmlns:saxon="http://saxon.sf.net/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xhtml cinclude" version="2.0">
	<xsl:include href="templates.xsl"/>

	<xsl:param name="id"/>
	<xsl:param name="serverName "/>
	<xsl:param name="serverPort "/>
	<xsl:param name="requestURI "/>

	<xsl:variable name="uri">
		<xsl:text>http://</xsl:text>
		<xsl:value-of select="$serverName"/>
		<xsl:if test="$serverPort = '8080'">
			<xsl:text>:</xsl:text>
			<xsl:value-of select="$serverPort"/>
		</xsl:if>
		<xsl:value-of select="$requestURI"/>
	</xsl:variable>

	<xsl:variable name="display_path">../</xsl:variable>

	<xsl:template match="/">
		<xsl:variable name="typeof" select="/xhtml:div/@typeof"/>

		<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml"
			prefix="nm: http://nomisma.org/id/
			dcterms: http://purl.org/dc/terms/
			foaf: http://xmlns.com/foaf/0.1/
			gml:  http://www.opengis.net/gml/
			owl:  http://www.w3.org/2002/07/owl#
			rdfs: http://www.w3.org/2000/01/rdf-schema#
			rdfa: http://www.w3.org/ns/rdfa#
			rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
			skos: http://www.w3.org/2004/02/skos/core#"
			vocab="http://nomisma.org/id/">
			<head>
				<title id="{$id}">
					<xsl:value-of select="$uri"/>
				</title>
				<style type="text/css">
					@import url(<xsl:value-of select="concat($display_path, 'style.css')"/>
					);</style>
				<style type="text/css">
					@import url(<xsl:value-of select="concat($display_path, 'jquery.fancybox-1.3.4.css')"/>
					);</style>

				<!-- javascripts -->
				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery.fancybox-1.3.4.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/display_functions.js"/>
				<!--<script src="http://isawnyu.github.com/awld-js/lib/requirejs/require.min.js" type="text/javascript"/>
				<script src="http://isawnyu.github.com/awld-js/awld.js?autoinit" type="text/javascript"/>-->

				<!-- only include mapping javascript files if necessary -->
				<xsl:if test="$typeof='mint' or $typeof='type_series_item' or $typeof='hoard'">
					<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
					<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.9&amp;sensor=false"/>
					<script type="text/javascript" src="{$display_path}javascript/display_map_functions.js"/>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<div id="source" class="center">					
					<xsl:copy-of select="*"/>
				</div>
				<!--<div id="source" class="center">
					<pre><xsl:value-of select="saxon:serialize(*, 'xhtml:div')"/></pre>
				</div>-->
				<xsl:if test="$typeof='mint' or $typeof='type_series_item' or $typeof='hoard'">
					<div class="center">
						<div id="mapcontainer"/>
					</div>
				</xsl:if>
				<xsl:if test="$typeof='type_series_item'">
					<cinclude:include src="cocoon:/widget?uri={concat('http://nomisma.org/id/', $id)}&amp;curie={$typeof}&amp;template=display"/>
				</xsl:if>
				<div class="center">
					<a href="http://www.w3.org/2012/pyRdfa/extract?uri={$uri}">RDF Triples (Turtle)</a>
					<a href="http://validator.w3.org/check?uri={$uri}">W3 HTML Validator</a>
					<a href="http://nomisma.org/nomisma.org.xml">Download all nomisma.org ids.</a>
				</div>

				<!-- footer -->
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<!--<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:div|xhtml:span">		
		<xsl:element name="{local-name()}">
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:for-each>
			<xsl:if test="string(@property)">
				<span class="prop"><xsl:value-of select="@property"/>: </span>				
			</xsl:if>			<xsl:apply-templates/>
			<xsl:if test="string(@resource)">
				<span class="res">(<xsl:value-of select="@resource"/>)</span>
				<a href="{@resource}" target="_new">
					<img src="http://upload.wikimedia.org/wikipedia/commons/6/64/Icon_External_Link.png"/>
				</a>
			</xsl:if>
		</xsl:element>
	</xsl:template>-->


</xsl:stylesheet>
