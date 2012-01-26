<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="xs" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:xxi="http://orbeon.org/oxf/xml/xinclude" xmlns:ov="http://open.vocab.org/terms/" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:fr="http://orbeon.org/oxf/xml/form-runner" xmlns:gml="http://www.opengis.net/gml/" xmlns:batlas="http://atlantides.org/batlas/" xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#"
	xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:xxforms="http://orbeon.org/oxf/xml/xforms" xmlns:cc="http://creativecommons.org/ns#"
	xmlns:nm="http://nomisma.org/id/" version="2.0">
	<xsl:output method="html" encoding="UTF-8"/>
	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<xsl:variable name="display_path">../</xsl:variable>


	<xsl:template match="/">
		<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>

		<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:batlas="http://atlantides.org/batlas/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:gml="http://www.opengis.net/gml/"
			xmlns:nm="http://nomisma.org/id/" xmlns:ov="http://open.vocab.org/terms/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2008/05/skos#">
			<head>
				<link rel="x-pelagios-oac-serialization" title="Pelagios compatible version" type="application/rdf+xml" href="http://nomisma.org/nomisma.org.pelagios.rdf"/>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
				<title>http://nomisma.org/id/<xsl:value-of select="$id"/></title>
				<base href="http://nomisma.org/id/"/>
				<!--
						<link rel="alternate" type="application/rdf+xml" href="http://www.w3.org/2007/08/pyRdfa/extract?uri=http%3A%2F%2Fnomisma.org%2Fid%2Fabila" />
					-->
				<link type="application/vnd.google-earth.kml+xml" href="http://nomisma.org/kml/{$id}.kml"/>
				<link type="application/vnd.google-earth.kml+xml" href="http://nomisma.org/kml/{$id}-all.kml"/>

				<!-- styling -->
				<link rel="stylesheet" type="text/css" href="{$display_path}/css/grids-min.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}/css/reset-fonts-grids.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}/css/base-min.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}/css/fonts-min.css"/>

				<!-- nomisma styling -->
				<link rel="stylesheet" href="{$display_path}/css/style.css"/>

				<!-- javascript -->
				<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
				<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
				<script type="text/javascript" src="{$display_path}/javascript/jquery-1.6.1.min.js"/>
				<script type="text/javascript" src="{$display_path}/javascript/map_functions.js"/>
				<script type="text/javascript">
					$(document).ready(function(){
						initialize_map('<xsl:value-of select="$id"/>');
					});
				</script>

			</head>
			<body class="yui-skin-sam">
				<div id="doc4">
					<div id="hd">
						<h1>header</h1> insert menu here: <span style="float:right"><a href="{$display_path}admin/edit/?id={$id}">edit id</a></span>
					</div>
					<div id="bd">
						<div id="yui-main">
							<div class="yui-b">
								<div class="yui-g">
									<div class="yui-u first">
										<xsl:apply-templates select="document(concat($exist-url, 'nomisma/id/', $id, '.xml'))/div"/>
									</div>
									<div class="yui-u">
										<div id="map"/>
									</div>
								</div>
							</div>
						</div>

					</div>
					<div id="ft">
						<div class="center">
							<a rel="license" href="http://creativecommons.org/licenses/by-nc/3.0/"><img alt="Creative Commons License" style="border-width:0"
									src="http://i.creativecommons.org/l/by-nc/3.0/88x31.png"/></a><br/><span xmlns:dc="http://purl.org/dc/elements/1.1/" property="dc:title">Nomisma.org</span> by <a
								xmlns:cc="http://creativecommons.org/ns#" href="http://nomisma.org" property="cc:attributionName" rel="cc:attributionURL">http://nomisma.org</a> is licensed under a <a
								rel="license" href="http://creativecommons.org/licenses/by-nc/3.0/">Creative Commons Attribution-Noncommercial 3.0 License</a>. </div>
						<div class="center">
							<span style="color:gray">All data in nomisma.org is preliminary and in the process of being updated.</span>
						</div>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="div">
		<div>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}" select="."/>
			</xsl:for-each>
			<h1>
				<xsl:value-of select="translate(replace(@typeof, 'nm:', ''), '[]', '')"/>
				<xsl:text>: </xsl:text>
				<xsl:apply-templates select="div[@property='skos:prefLabel']"/>
			</h1>
			<xsl:apply-templates select="div[@property='skos:definition']"/>
			<xsl:if test="count(div[@property='skos:altLabel']) &gt; 0">
				<h3>Alternate Labels</h3>
				<dl>
					<xsl:apply-templates select="div[@property='skos:altLabel']"/>
				</dl>
			</xsl:if>
			<xsl:if test="count(descendant::a[@rel='skos:related']) &gt; 0">
				<h3>Related Resources</h3>
				<dl>
					<xsl:apply-templates select="descendant::*[local-name()='a'][@rel='skos:related']"/>
				</dl>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="div[@property='skos:prefLabel']">
		<span>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}" select="."/>
			</xsl:for-each>
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="div[@property='skos:definition']">
		<p>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}" select="."/>
			</xsl:for-each>
			<xsl:value-of select="."/>
		</p>
	</xsl:template>

	<xsl:template match="div[@property='skos:altLabel']">
		<dt>
			<xsl:value-of select="nm:normalize-language(@xml:lang)"/>
		</dt>
		<dd>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}" select="."/>
			</xsl:for-each>
			<xsl:value-of select="."/>
		</dd>
	</xsl:template>

	<xsl:template match="*[local-name()='a'][@rel='skos:related']">
		<dt>
			<xsl:value-of select="nm:normalize-href(@href)"/>
		</dt>
		<dd>
			<a>
				<xsl:for-each select="@*">
					<xsl:attribute name="{name()}" select="."/>
				</xsl:for-each>
				<xsl:value-of select="@href"/>
			</a>
		</dd>
	</xsl:template>

	<!-- ***************** FUNCTIONS ******************* -->
	<xsl:function name="nm:normalize-language">
		<xsl:param name="lang"/>

		<xsl:choose>
			<xsl:when test="$lang='de'">German</xsl:when>
			<xsl:when test="$lang='en'">English</xsl:when>
			<xsl:when test="$lang='fr'">French</xsl:when>
			<xsl:when test="$lang='it'">Italian</xsl:when>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="nm:normalize-href">
		<xsl:param name="href"/>

		<xsl:choose>
			<xsl:when test="contains($href, 'pleiades')">Pleiades</xsl:when>
			<xsl:when test="contains($href, 'wikipedia')">Wikipedia</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="tokenize(substring-after($href, 'http://'), '/')[1]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
