<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:skos="http://www.w3.org/2004/02/skos/core#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>


	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:variable name="versions" as="item()*">
		<xsl:for-each select="/content/directory/file">
			<xsl:sort select="tokenize(@name, '\.')[2]" data-type="number" order="ascending"/>
			<xsl:value-of select="tokenize(@name, '\.')[2]"/>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="version"
		select="
			if (tokenize(doc('input:request')/request/request-url, '/')[last()] != 'ontology') then
				tokenize(doc('input:request')/request/request-url, '/')[last()]
			else
				$versions[last()]"/>

	<xsl:variable name="path"
		select="
			if (tokenize(doc('input:request')/request/request-url, '/')[last()] != 'ontology') then
				concat('ontology/', $version)
			else
				'ontology'"/>

	<xsl:variable name="display_path"
		select="
			if (tokenize(doc('input:request')/request/request-url, '/')[last()] != 'ontology') then
				'../'
			else
				'./'"/>

	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="//rdf:RDF/namespace::*[not(name() = 'xml')]">
				<namespace prefix="{if (string(name())) then name() else 'nmo'}" uri="{.}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: Ontology</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://code.jquery.com/jquery-latest.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
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
					<h1>Nomisma Ontology</h1>

					<p>The namespace for all terms is <code>http://nomisma.org/ontology#</code></p>

					<p>Download OWL ontology for this version: <a href="{concat($url, $path, '.rdf')}">RDF/XML</a>
						<xsl:text>, </xsl:text>
						<a href="{concat($url, $path, '.ttl')}">TTL</a></p>
					
					<p>See the <a href="https://nomisma.hypotheses.org/the-nomisma-org-cookbook">Nomisma Cookbook</a> for further documentation on properties and classes within the ontology, with example models.</p>
					
					<!-- version history -->
					<div>
						<xsl:apply-templates select="/content/directory"/>
					</div>

					<div>
						<h2>Cross reference for Nomisma classes and properties</h2>
						<h3>Classes</h3>
						<xsl:apply-templates select="descendant::owl:Class[starts-with(@rdf:about, 'http://nomisma.org/')]"/>
						<h3>Properties</h3>
						<xsl:apply-templates select="descendant::owl:ObjectProperty[starts-with(@rdf:about, 'http://nomisma.org/')]"/>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="directory">
		<xsl:variable name="date" select="concat('20', substring($version, 1, 2), '-', substring($version, 3, 2), '-', substring($version, 5, 2))"/>

		<dl>
			<dt>This version:</dt>
			<dd>
				<a href="{concat($url, 'ontology/', $version)}">
					<xsl:value-of select="concat($url, 'ontology/', $version)"/>
				</a>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="format-date(xs:date($date), '[D01] [MNn] [Y0001]')"/>
				<xsl:text>)</xsl:text>
			</dd>
			<dt>Latest published version:</dt>
			<dd>
				<a href="{concat($url, 'ontology')}">
					<xsl:value-of select="concat($url, 'ontology')"/>
				</a>
			</dd>
			<dt>Previous versions:</dt>
			<dd>
				<xsl:for-each select="$versions">
					<xsl:sort order="descending" data-type="number"/>

					<xsl:if test=". &lt; $version">
						<xsl:variable name="date" select="concat('20', substring(., 1, 2), '-', substring(., 3, 2), '-', substring(., 5, 2))"/>

						<a href="{concat($url, 'ontology/', .)}">
							<xsl:value-of select="concat($url, 'ontology/', .)"/>
						</a>
						<xsl:text> (</xsl:text>
						<xsl:value-of select="format-date(xs:date($date), '[D01] [MNn] [Y0001]')"/>
						<xsl:text>)</xsl:text>
						<br/>
					</xsl:if>
				</xsl:for-each>
			</dd>
		</dl>
	</xsl:template>

	<!-- styling for classes and properties -->
	<xsl:template match="owl:Class | owl:ObjectProperty">
		<xsl:variable name="uri" select="@rdf:about"/>
		<xsl:variable name="curie"
			select="
				if ($namespaces//namespace[starts-with($uri, @uri)]) then
					replace($uri, $namespaces//namespace[starts-with($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))
				else
					$uri"/>

		<div id="{substring-after(@rdf:about, '#')}" class="entity">
			<h4>
				<xsl:value-of select="local-name()"/>
				<xsl:text>: </xsl:text>
				<a href="#{substring-after(@rdf:about, '#')}">
					<xsl:value-of select="$curie"/>
				</a>
			</h4>
			<p>
				<strong>IRI: </strong>
				<code>
					<xsl:value-of select="@rdf:about"/>
				</code>
			</p>

			<xsl:choose>
				<xsl:when test="rdfs:comment">
					<xsl:apply-templates select="rdfs:comment"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="//rdf:Description[@rdf:about = $uri]/rdfs:comment"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:apply-templates select="owl:deprecated"/>

			<div class="description">
				<dl>
					<xsl:if test="self::owl:Class">
						<xsl:if test="//owl:Class[rdfs:subClassOf/@rdf:resource = $uri]">
							<dt>has subclasses</dt>
							<dd>
								<xsl:apply-templates select="//rdfs:subClassOf[@rdf:resource = $uri]/parent::owl:Class" mode="relation"/>
							</dd>
						</xsl:if>
						<xsl:if test="rdfs:subClassOf">
							<dt>has superclasses</dt>
							<dd>
								<xsl:apply-templates select="rdfs:subClassOf" mode="relation"/>
							</dd>
						</xsl:if>
					</xsl:if>
					<xsl:if test="self::owl:ObjectProperty">
						<xsl:if test="//owl:ObjectProperty[rdfs:subPropertyOf/@rdf:resource = $uri]">
							<dt>has subproperties</dt>
							<dd>
								<xsl:apply-templates select="//rdfs:subPropertyOf[@rdf:resource = $uri]/parent::owl:ObjectProperty" mode="relation"/>
							</dd>
						</xsl:if>
						<xsl:if test="rdfs:subPropertyOf">
							<dt>has superproperties</dt>
							<dd>
								<xsl:apply-templates select="rdfs:subPropertyOf" mode="relation"/>
							</dd>
						</xsl:if>
						<xsl:if test="rdfs:domain">
							<dt>has domain</dt>
							<dd>
								<xsl:apply-templates select="rdfs:domain" mode="relation"/>
							</dd>
						</xsl:if>
						<xsl:if test="rdfs:range">
							<dt>has range</dt>
							<dd>
								<xsl:apply-templates select="rdfs:range" mode="relation"/>
							</dd>
						</xsl:if>
					</xsl:if>
				</dl>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="rdfs:comment | owl:deprecated">
		<div class="{local-name()}">
			<p>
				<xsl:value-of select="."/>
			</p>
		</div>
	</xsl:template>

	<!-- links that are related to classes and properties -->
	<xsl:template match="rdfs:subClassOf | rdfs:subPropertyOf | rdfs:domain | rdfs:range | owl:Class | owl:ObjectProperty" mode="relation">
		<xsl:variable name="uri" select="
				if (@rdf:resource) then
					@rdf:resource
				else
					@rdf:about"/>

		<a href="#{substring-after($uri, '#')}">
			<xsl:value-of
				select="
					if ($namespaces//namespace[starts-with($uri, @uri)]) then
						replace($uri, $namespaces//namespace[starts-with($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))
					else
						$uri"
			/>
		</a>
		<xsl:if test="not(position() = last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
