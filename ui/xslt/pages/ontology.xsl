<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:variable name="display_path"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: Ontology</title>
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
				<div class="col-md-3">
					<h3>Classes</h3>
					<ul>
						<xsl:apply-templates select="descendant::owl:Class" mode="toc"/>
					</ul>
					<h3>Properties</h3>
					<ul>
						<xsl:apply-templates select="descendant::owl:ObjectProperty" mode="toc"/>
					</ul>
				</div>
				<div class="col-md-9">
					<h1>Nomisma Ontology</h1>
					<div>
						<h2>Versions</h2>
						<xsl:apply-templates select="/content/directory"/>
					</div>
					<div>
						<h2>Classes</h2>
						<xsl:apply-templates select="descendant::owl:Class" mode="body"/>
					</div>
					<div>
						<h2>Properties</h2>
						<xsl:apply-templates select="descendant::owl:ObjectProperty" mode="body"/>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="directory">
		<xsl:variable name="versions" as="item()*">
			<xsl:for-each select="//file">
				<xsl:sort/>
				<xsl:value-of select="tokenize(@name, '\.')[2]"/>
			</xsl:for-each>
		</xsl:variable>

		<table class="table">
			<thead>
				<tr>
					<th>Version</th>
					<th>RDF/XML</th>
					<th>TTL</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="distinct-values($versions)">
					<xsl:variable name="version" select="."/>
					<tr>
						<td>
							<xsl:variable name="date" select="concat('20', substring($version, 1, 2), '-', substring($version, 3, 2), '-', substring($version, 5, 2))"/>
							<xsl:value-of select="format-date(xs:date($date), '[D01] [MNn] [Y0001]')"/>

						</td>
						<td>
							<a href="{$display_path}ontology.{$version}.rdf">
								<xsl:value-of select="concat($url, 'ontology.', $version, '.rdf')"/>
							</a>
						</td>
						<td>
							<a href="{$display_path}ontology.{$version}.ttl">
								<xsl:value-of select="concat($url, 'ontology.', $version, '.ttl')"/>
							</a>
						</td>
					</tr>
				</xsl:for-each>
				<tr>
					<td>Current</td>
					<td>
						<a href="{$display_path}ontology.rdf">
							<xsl:value-of select="concat($url, 'ontology.rdf')"/>
						</a>
					</td>
					<td>
						<a href="{$display_path}ontology.ttl">
							<xsl:value-of select="concat($url, 'ontology.ttl')"/>
						</a>
					</td>
				</tr>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="owl:Class|owl:ObjectProperty" mode="toc">
		<li>
			<a href="#{substring-after(@rdf:about, '#')}">
				<xsl:value-of select="substring-after(@rdf:about, '#')"/>
			</a>
		</li>
	</xsl:template>
	
	<xsl:template match="owl:Class|owl:ObjectProperty" mode="body">
		<div id="{substring-after(@rdf:about, '#')}" class="def">
			<h4>
				<xsl:value-of select="substring-after(@rdf:about, '#')"/>
			</h4>
			<xsl:if test="string(normalize-space(skos:definition))">
				<dl class="dl-horizontal">
					<dt>Definition</dt>
					<dd><xsl:value-of select="skos:definition"/></dd>
				</dl>
			</xsl:if>
		</div>
	</xsl:template>

</xsl:stylesheet>
