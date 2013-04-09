<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dir="http://apache.org/cocoon/directory/2.0"
	xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs dir" version="2.0">
	<xsl:include href="templates.xsl"/>
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
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/>
				<title>Nomisma: all ids</title>
				<style type="text/css">
					@import url(<xsl:value-of select="concat($display_path, 'style.css')"/>
					);</style>
				<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"/>
			</head>
			<body>
				<!-- header -->
				<xsl:call-template name="header"/>

				<div class="center">
					<ul>
						<xsl:apply-templates select="descendant::dir:file"/>
					</ul>
				</div>

				<!-- footer -->
				<xsl:call-template name="footer"/>

			</body>
		</html>
	</xsl:template>

	<xsl:template match="dir:file">
		<xsl:variable name="id" select="substring-before(@name, '.txt')"/>
		<li>
			<a href="{$id}">
				<xsl:value-of select="$id"/>
			</a>
		</li>
	</xsl:template>

</xsl:stylesheet>
