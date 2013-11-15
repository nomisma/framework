<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="templates.xsl"/>

	<xsl:param name="requestURI"/>
	<xsl:param name="pageTitle"/>
	<xsl:variable name="display_path">../</xsl:variable>

	<xsl:template match="/">
		<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml"
			prefix="nm: http://nomisma.org/id/
			dcterms: http://purl.org/dc/terms/
			foaf: http://xmlns.com/foaf/0.1/
			geo:  http://www.w3.org/2003/01/geo/wgs84_pos#
			owl:  http://www.w3.org/2002/07/owl#
			rdfs: http://www.w3.org/2000/01/rdf-schema#
			rdfa: http://www.w3.org/ns/rdfa#
			rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
			skos: http://www.w3.org/2004/02/skos/core#"
			vocab="http://nomisma.org/id/">
			<head>
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/>
				<title>
					<xsl:value-of select="$pageTitle"/>
				</title>
				<style type="text/css">
					@import url(http://nomisma.org/style.css);</style>
				<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"/>
			</head>
			<body>
				<div class="center"> Nomisma.org: [<a href="http://nomisma.org/">home</a>] [<a href="http://nomisma.org/sparql">sparql</a>] [<a href="http://nomisma.org/apis"
					>apis</a>] [<a href="http://nomisma.org/flickr">flickr machine tags</a>] [<a href="http://nomisma.org/id/">all ids</a>] "Common currency for digital
					numismatics." </div>

				<!-- get content -->
				<div id="source" class="center">
					<h1>
						<xsl:value-of select="$pageTitle"/>
					</h1>

					<p>The following resource was not found on nomisma.org: <xsl:value-of select="substring-after($requestURI, 'nomisma/')"/></p>
					<xsl:if test="contains($requestURI, 'id/')">
						<xsl:variable name="id" select="tokenize($requestURI, '/')[last()]"/>
						<p><a href="http://nomisma.org:8080/orbeon/nomisma/edit/?create={$id}">Create id <xsl:value-of select="$id"/></a></p>
					</xsl:if>
				</div>

				<!-- footer -->
				<xsl:call-template name="footer"/>

			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
