<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:variable name="display_path"/>
	
	<xsl:variable name="datasets" as="element()*">
		<xsl:copy-of select="descendant::res:sparql"/>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: Datasets</title>
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
					<xsl:apply-templates select="descendant::res:sparql"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="res:sparql">
		<!-- evaluate the type of response to handle ASK and SELECT -->
		<xsl:choose>
			<xsl:when test="res:results">
				<h1>Datasets</h1>
				<xsl:choose>
					<xsl:when test="count(descendant::res:result) &gt; 0">
						<table class="table table-striped table-responsive">
							<thead>
								<tr>
									<th>Dataset</th>
									<th>Description</th>
									<th>Publisher</th>
									<th class="text-center">License</th>
									<th class="text-center">Count</th>
									<th class="text-center">Data Dump</th>									
								</tr>
							</thead>
							<tbody>			
								<xsl:for-each select="distinct-values(descendant::res:result/res:binding[@name='dataset']/res:uri)">
									<xsl:variable name="uri" select="."/>
									<xsl:variable name="result" as="element()*">
										<xsl:copy-of select="$datasets//res:result[res:binding[@name='dataset']/res:uri = $uri][1]"/>
									</xsl:variable>
																		
									<xsl:apply-templates select="$result">
										<xsl:with-param name="dumps" select="$datasets//res:result[res:binding[@name='dataset']/res:uri = $uri]/res:binding[@name='dump']/res:uri"/>
									</xsl:apply-templates>
								</xsl:for-each>								
							</tbody>
						</table>
					</xsl:when>
					<xsl:otherwise>
						<p>No datasets available in the SPARQL endpoint.</p>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:param name="dumps"/>
		
		<tr>
			<td>
				<a href="{res:binding[@name='dataset']/res:uri}">
					<xsl:value-of select="res:binding[@name='title']/res:literal"/>
				</a>
			</td>
			<td>
				<xsl:value-of select="res:binding[@name='description']/res:literal"/>
			</td>
			<td>
				<xsl:value-of select="res:binding[@name='publisher']/res:literal"/>
			</td>
			<td class="text-center">
				<!-- display license first if available, otherwise rights -->
				<xsl:choose>
					<xsl:when test="res:binding[@name='license']">
						<a href="{res:binding[@name='license']/res:uri}">
							<xsl:variable name="license" select="res:binding[@name='license']/res:uri"/>
							<xsl:choose>
								<xsl:when test="matches($license, '^https?://opendatacommons.org/licenses/odbl/')">ODC-ODbL</xsl:when>
								<xsl:when test="matches($license, '^https?://opendatacommons.org/licenses/by/')">ODC-by</xsl:when>
								<xsl:when test="matches($license, '^https?://opendatacommons.org/licenses/pddl/')">ODC-PDDL</xsl:when>
								<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by/')">
									<img src="http://i.creativecommons.org/l/by/3.0/88x31.png" alt="CC BY" title="CC BY"/>
								</xsl:when>
								<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by-nd/')">
									<img src="http://i.creativecommons.org/l/by-nd/3.0/88x31.png" alt="CC BY-ND" title="CC BY-ND"/>
								</xsl:when>
								<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by-nc-sa/')">
									<img src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" alt="CC BY-NC-SA" title="CC BY-NC-SA"/>
								</xsl:when>
								<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by-sa/')">
									<img src="http://i.creativecommons.org/l/by-sa/3.0/88x31.png" alt="CC BY-SA" title="CC BY-SA"/>
								</xsl:when>
								<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by-nc/')">
									<img src="http://i.creativecommons.org/l/by-nc/3.0/88x31.png" alt="CC BY-NC" title="CC BY-NC"/>
								</xsl:when>
								<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by-nc-nd/')">
									<img src="http://i.creativecommons.org/l/by-nc-nd/3.0/88x31.png" alt="CC BY-NC-ND" title="CC BY-NC-ND"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="res:binding[@name='license']/res:uri"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:when>
					<xsl:when test="res:binding[@name='rights']">
						<xsl:value-of select="res:binding[@name='rights']/res:literal"/>
					</xsl:when>
				</xsl:choose>				
			</td>
			<td class="text-center">
				<xsl:value-of select="res:binding[@name='count']/res:literal"/>
			</td>
			<td class="text-center">
				<xsl:for-each select="$dumps">
					<a href="{.}" title="{.}">
						<span class="glyphicon glyphicon-download-alt"/>
					</a>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>
