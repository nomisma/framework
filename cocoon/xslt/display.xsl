<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
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
				<title>
					<xsl:value-of select="$uri"/>
				</title>
				<style type="text/css">
					@import url(<xsl:value-of select="concat($display_path, 'css/style.css')"/>);
				</style>
				
				<!-- javascripts -->
				<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"/>
				<script src="http://isawnyu.github.com/awld-js/lib/requirejs/require.min.js" type="text/javascript"/>
				<script src="http://isawnyu.github.com/awld-js/awld.js?autoinit" type="text/javascript"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<div id="source" class="center">
					<xsl:copy-of select="*"/>
				</div>
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

</xsl:stylesheet>
