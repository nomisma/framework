<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="xs"
	version="2.0">
	<xsl:include href="../../templates.xsl"/>

	<xsl:variable name="project" select="tokenize(substring-after(doc('input:request')/request/request-url, 'project/'), '/')[1]"/>
	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="string-length($project) &gt; 0">../../</xsl:when>
			<xsl:otherwise>../</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: Authorized Namespaces</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script type="text/javascript" src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
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
					<h1>Authorized Namespaces</h1>
					<xsl:choose>
						<xsl:when test="count(descendant::res:result) = 0">
							<p>No project of this name has been recorded by nomisma.</p>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="descendant::res:result"/>
						</xsl:otherwise>
					</xsl:choose>

				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="res:result">
		<div class="highlight">
			<h2>
				<a href="{substring-after(res:binding[@name='seeAlso']/res:uri, 'project/')}">
					<xsl:value-of select="res:binding[@name='title']/res:literal"/>
				</a>
			</h2>
			<dl class="dl-horizontal">
				<xsl:for-each select="res:binding[not(@name='seeAlso') and not(@name='title')]">
					<dt>
						<xsl:value-of select="@name"/>
					</dt>
					<dd>
						<xsl:choose>
							<xsl:when test="res:literal">
								<xsl:value-of select="res:literal"/>
							</xsl:when>
							<xsl:otherwise>
								<a href="{res:uri}">
									<xsl:value-of select="res:uri"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</dd>
				</xsl:for-each>
			</dl>
		</div>
	</xsl:template>
</xsl:stylesheet>
