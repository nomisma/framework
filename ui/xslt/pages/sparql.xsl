<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../templates.xsl"/>
	
	<xsl:param name="lang">en</xsl:param>

	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: SPARQL</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script type="text/javascript" src="http://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/codemirror.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/matchbrackets.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/sparql.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/sparql_functions.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/codemirror.css"/>
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
		<xsl:variable name="default-query">
			<xsl:variable name="select"><![CDATA[SELECT * WHERE {
  ?s ?p ?o
} LIMIT 100]]></xsl:variable>

			<xsl:apply-templates select="/config/namespaces/namespace[@default = true()]">
				<xsl:sort select="@prefix"/>
			</xsl:apply-templates>
			<xsl:text>&#x00a;</xsl:text>
			<xsl:value-of select="$select"/>
		</xsl:variable>

		<div class="container-fluid content">
			<div class="row">
				<div class="col-md-12">
					<h1>SPARQL Query</h1>
					<p>For examples, see <a href="{$display_path}documentation/sparql">SPARQL Examples</a>. A basic tutorial on SPARQL is available from <a
							href="http://jena.apache.org/tutorials/sparql.html">Apache Jena</a>.</p>
					<form role="form" id="sparqlForm" action="{$display_path}query" method="GET" accept-charset="UTF-8">
						<textarea name="query" rows="20" class="form-control" id="code">
							<xsl:value-of select="$default-query"/>
						</textarea>
						<br/>
						<div class="col-md-6">
							<div class="form-group">
								<h4>Additional prefixes</h4>
								<ul class="list-inline">
									<xsl:for-each select="/config/namespaces/namespace">
										<xsl:sort select="@prefix"/>
										
										<li>
											<xsl:if test="@default = true()">
												<xsl:attribute name="class">hidden</xsl:attribute>
											</xsl:if>
											<button class="prefix-button btn btn-default" title="{@uri}" uri="{@uri}">
												<xsl:value-of select="@prefix"/>
											</button>
										</li>
									</xsl:for-each>
								</ul>
							</div>

							<div class="form-group">
								<label for="output">Output</label>
								<select name="output" class="form-control">
									<option value="html">HTML</option>
									<option value="xml">XML</option>
									<option value="json">JSON</option>
									<option value="text">Text</option>
									<option value="csv">CSV</option>
								</select>
							</div>
							<button type="submit" class="btn btn-default">Submit</button>
						</div>
						<div class="col-md-6">
							<p class="text-info">This endpoint (<xsl:value-of select="concat(/config/url, 'query')"/>) supports content negotiation for the following content types
								with SELECT queries: <code>text/html</code>, <code>text/csv</code>, <code>text/plain</code>, <code>application/sparql-results+json</code>, and
									<code>application/sparql-results+xml</code></p>

							<p class="text-info">When querying for geo:lat and geo:long properties, a map will be generated, and geographic data may be downloaded as GeoJSON and
								KML.</p>
						</div>
					</form>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="namespace">
		<xsl:text>PREFIX </xsl:text>
		<xsl:value-of select="@prefix"/>
		<xsl:text>: &lt;</xsl:text>
		<xsl:value-of select="@uri"/>
		<xsl:text>&gt;&#x00a;</xsl:text>
	</xsl:template>

</xsl:stylesheet>
