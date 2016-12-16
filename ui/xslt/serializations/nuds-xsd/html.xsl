<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>

	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: Numismatic Description Schema (NUDS)</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/result_functions.js"/>
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>

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
				<div class="col-md-12">
					<h1>Numismatic Description Schema</h1>
					<p>Placeholder for documentation on NUDS XSD</p>
					<h3>Elements</h3>
					<xsl:apply-templates select="descendant::xs:element" mode="toc">
						<xsl:sort select="@name" order="ascending"/>
					</xsl:apply-templates>
					<h3>Attributes</h3>
					<hr/>
					<xsl:apply-templates select="descendant::xs:element" mode="desc">
						<xsl:sort select="@name" order="ascending"/>
					</xsl:apply-templates>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="xs:element" mode="toc">
		<a href="#{@name}">
			<xsl:value-of select="@name"/>
		</a>
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="xs:element" mode="desc">
		<div id="{@name}">
			<h4>
				<xsl:value-of select="@name"/>
			</h4>
			<xsl:apply-templates select="xs:annotation/xs:documentation"/>
		</div>
	</xsl:template>

	<xsl:template match="xs:documentation">
		<p>
			<xsl:value-of select="."/>
		</p>
	</xsl:template>

</xsl:stylesheet>
