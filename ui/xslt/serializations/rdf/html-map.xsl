<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" exclude-result-prefixes="#all" version="2.0">

	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="id" select="tokenize(/content/rdf:RDF/*[1]/@rdf:about, '/')[last()]"/>
	<xsl:variable name="html-uri" select="concat(/content/config/url, 'id/', $id, '.html')"/>
	<xsl:variable name="type" select="/content/rdf:RDF/*[1]/name()"/>
	<xsl:variable name="title" select="/content/rdf:RDF/*[1]/skos:prefLabel[@xml:lang='en']"/>

	<!-- flickr -->
	<xsl:variable name="flickr_api_key" select="/content/config/flickr_api_key"/>
	<!--<xsl:variable name="service" select="concat('http://api.flickr.com/services/rest/?api_key=', $flickr_api_key)"/>-->

	<!-- sparql -->
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_query"/>

	<!-- definition of namespaces for turning in solr type field URIs into abbreviations -->
	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="//rdf:RDF/namespace::*[not(name()='xml')]">
				<namespace prefix="{name()}" uri="{.}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>

	<xsl:variable name="classes" as="item()*">
		<classes>
			<class map="false" types="false" prop="nmo:hasCollection">nmo:Collection</class>
			<class map="true" types="true" prop="nmo:hasDenomination" dist="true">nmo:Denomination</class>
			<class map="true" types="true" prop="dynasty" dist="true">rdac:Family</class>
			<class map="true" types="false">nmo:Ethnic</class>
			<class map="false" types="false">nmo:FieldOfNumismatics</class>
			<class map="true" types="false">nmo:Hoard</class>
			<class map="true" types="true" prop="nmo:hasManufacture" dist="true">nmo:Manufacture</class>
			<class map="true" types="true" prop="nmo:hasMaterial" dist="true">nmo:Material</class>
			<class map="true" types="true" prop="nmo:hasMint" dist="true">nmo:Mint</class>
			<class map="false" types="false">nmo:NumismaticTerm</class>
			<class map="true" types="false">nmo:ObjectType</class>
			<class map="true" types="true" prop="?prop" dist="true">foaf:Group</class>
			<class map="true" types="true" prop="?prop" dist="true">foaf:Organization</class>
			<class map="true" types="true" prop="?prop" dist="true">foaf:Person</class>
			<class map="false" types="false">crm:E4_Period</class>
			<class>nmo:ReferenceWork</class>
			<class map="true" types="true" prop="nmo:hasRegion" dist="true">nmo:Region</class>
			<class map="false" types="false">org:Role</class>
			<class map="false" types="false">nmo:TypeSeries</class>
			<class map="false" types="false">un:Uncertainty</class>
			<class map="false" types="false">nmo:CoinWear</class>
			<class map="true" types="true" dist="true" prop="deity">wordnet:Deity</class>
		</classes>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title id="{$id}">nomisma.org: <xsl:value-of select="$id"/> (map)</title>
				<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
				<script type="text/javascript" src="http://code.jquery.com/jquery-2.1.4.min.js"/>

				<xsl:if test="$classes//class[text()=$type]/@map=true()">
					<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
					<script type="text/javascript" src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/leaflet.ajax.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/heatmap.min.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/leaflet-heatmap.js"/>
					<script type="text/javascript" src="{$display_path}ui/javascript/display_map_functions.js"/>
					<style type="text/css">
						body {
							padding: 0;
							margin:0;
						}
						html,
						body,
						.map-fullscreen{
							height:100%;
						}</style>
				</xsl:if>
				<!--<link rel="stylesheet" href="{$display_path}ui//css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$display_path}ui//javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/display_functions.js"/>-->
				<!--<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>-->

			</head>
			<body>
				<xsl:call-template name="body"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<div id="mapcontainer" class="map-fullscreen">
			<div id="info"/>
		</div>

		<!-- variables retrieved from the config and used in javascript -->
		<div style="display:none">
			<span id="mapboxKey">
				<xsl:value-of select="/content/config/mapboxKey"/>
			</span>
			<span id="type">
				<xsl:value-of select="$type"/>
			</span>
			<span id="mode">fullscreen</span>
			<span id="path">../id/</span>
		</div>
	</xsl:template>
</xsl:stylesheet>
