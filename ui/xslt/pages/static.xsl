<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: April 2022
	Function: Serialize an HTML page to replace static pages that have been migrated into the Jekyll Nomisma site -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../templates.xsl"/>
	
	<xsl:param name="paths" select="tokenize(substring-after(doc('input:request')/request/request-uri, 'nomisma/'), '/')"/>	
	
	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="count($paths) &lt;= 1">./</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="count" select="count($paths) - 1"/>
				<xsl:variable name="path" select="for $i in $count  return '../'"/>	
				
				<xsl:value-of select="replace($path, ' ', '')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://code.jquery.com/jquery-latest.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>				
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
					<h1>Nomisma Static Page</h1>

					<p>This URL pattern in the Nomisma.org Orbeon-based XPL framework has been replaced with a static representation in the <a
							href="https://github.com/nomisma/site">Jekyll site</a>.</p>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
