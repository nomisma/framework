<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="templates.xsl"/>

	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/>
				<title>Nomisma APIs</title>
				<style type="text/css">
					@import url(<xsl:value-of select="concat($display_path, 'style.css')"/>
					);</style>
			</head>
			<body>
				<xsl:call-template name="header"/>

				<div class="center">
					<h1>Nomisma API Documentation</h1>
					<table id="api-table">
						<thead>
							<tr>
								<th style="width:50%">API</th>
								<th>XML</th>
								<th>JSON</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td>
									<a href="#avgAxis">avgAxis</a>
								</td>
								<td>
									<a href="apis/avgAxis?constraints=nm:type_series_item &lt;http://numismatics.org/ocre/id/ric.1(2).aug.1a&gt;">XML</a>
								</td>
								<td/>
							</tr>
							<tr>
								<td>
									<a href="#avgDiameter">avgDiameter</a>
								</td>
								<td>
									<a href="apis/avgDiameter?constraints=nm:type_series_item &lt;http://numismatics.org/ocre/id/ric.1(2).aug.1a&gt;">XML</a>
								</td>
								<td/>
							</tr>
							<tr>
								<td>
									<a href="#avgWeight">avgWeight</a>
								</td>
								<td>
									<a href="apis/avgWeight?constraints=nm:type_series_item &lt;http://numismatics.org/ocre/id/ric.1(2).aug.1a&gt;">XML</a>
								</td>
								<td/>
							</tr>
							<tr>
								<td>
									<a href="#closingDate">closingDate</a>
								</td>
								<td>
									<a href="apis/closingDate?identifiers=http://nomisma.org/id/rrc-385.4|http://nomisma.org/id/rrc-409.2|http://numismatics.org/ocre/id/ric.1(2).aug.1a">XML</a>
								</td>
								<td/>
							</tr>
							<tr>
								<td>
									<a href="#getLabel">getLabel</a>
								</td>
								<td>
									<a href="apis/getLabel?uri=http://nomisma.org/id/ar&amp;lang=fr">XML</a>
								</td>
								<td/>
							</tr>
						</tbody>
					</table>
					<div>
						<a name="avgAxis"/>
						<h2>Average Axis</h2>
						<p>Get average axis for given SPARQL query.<br/>
							<b>Webservice Type</b> : REST<br/>
							<b>Url</b> : nomisma.org/avgAxis?<br/>
							<b>Parameters</b> : constraints (following predicate - object format. multiple contraints separated by ' AND '. See examples below)<br/>
							<b>Result</b> : returns a decimal number in a response wrapper.<br/>
							<b>Examples</b>: <a
								href="apis/avgAxis?constraints=dcterms:partOf &lt;http://nomisma.org/id/ric> AND nm:mint &lt;http://nomisma.org/id/rome> AND nm:denomination &lt;http://nomisma.org/id/denarius>"
								>http://nomisma.org/apis/avgAxis?constraints=dcterms:partOf &lt;http://nomisma.org/id/ric> AND nm:mint &lt;http://nomisma.org/id/rome> AND nm:denomination
								&lt;http://nomisma.org/id/denarius></a>
							<br/>
							<a href="apis/avgAxis?constraints=nm:type_series_item &lt;http://numismatics.org/ocre/id/ric.1(2).aug.1a&gt;"
								>http://nomisma.org/apis/avgWeight?constraints=nm:type_series_item &lt;http://numismatics.org/ocre/id/ric.1(2).aug.1a&gt;</a>
						</p>
					</div>
					<div>
						<a name="avgDiameter"/>
						<h2>Average Diameter</h2>
						<p>Get average diameter for given SPARQL query.<br/>
							<b>Webservice Type</b> : REST<br/>
							<b>Url</b> : nomisma.org/avgDiameter?<br/>
							<b>Parameters</b> : constraints (following predicate - object format. multiple contraints separated by ' AND '. See examples below)<br/>
							<b>Result</b> : returns a decimal number in a response wrapper.<br/>
							<b>Examples</b>: <a
								href="apis/avgDiameter?constraints=dcterms:partOf &lt;http://nomisma.org/id/ric> AND nm:mint &lt;http://nomisma.org/id/rome> AND nm:denomination &lt;http://nomisma.org/id/denarius>"
								>http://nomisma.org/apis/avgDiameter?constraints=dcterms:partOf &lt;http://nomisma.org/id/ric> AND nm:mint &lt;http://nomisma.org/id/rome> AND nm:denomination
								&lt;http://nomisma.org/id/denarius></a>
							<br/>
							<a href="apis/avgDiameter?constraints=nm:type_series_item &lt;http://numismatics.org/ocre/id/ric.1(2).aug.1a&gt;"
								>http://nomisma.org/apis/avgDiameter?constraints=nm:type_series_item &lt;http://numismatics.org/ocre/id/ric.1(2).aug.1a&gt;</a>
						</p>
					</div>
					<div>
						<a name="avgWeight"/>
						<h2>Average Weight</h2>
						<p>Get average weight for given SPARQL query.<br/>
							<b>Webservice Type</b> : REST<br/>
							<b>Url</b> : nomisma.org/avgWeight?<br/>
							<b>Parameters</b> : constraints (following predicate - object format. multiple contraints separated by ' AND '. See examples below)<br/>
							<b>Result</b> : returns a decimal number in a response wrapper.<br/>
							<b>Examples</b>: <a
								href="apis/avgWeight?constraints=dcterms:partOf &lt;http://nomisma.org/id/ric> AND nm:mint &lt;http://nomisma.org/id/rome> AND nm:denomination &lt;http://nomisma.org/id/denarius>"
								>http://nomisma.org/apis/avgWeight?constraints=dcterms:partOf &lt;http://nomisma.org/id/ric> AND nm:mint &lt;http://nomisma.org/id/rome> AND nm:denomination
								&lt;http://nomisma.org/id/denarius></a>
							<br/>
							<a href="apis/avgWeight?constraints=nm:type_series_item &lt;http://numismatics.org/ocre/id/ric.1(2).aug.1a&gt;"
								>http://nomisma.org/apis/avgWeight?constraints=nm:type_series_item &lt;http://numismatics.org/ocre/id/ric.1(2).aug.1a&gt;</a>
						</p>
					</div>
					<div>
						<a name="closingDate"/>
						<h2>Closing Date</h2>
						<p>Get the closing date of a hoard based on coin type URIs provided in the request parameter.<br/>
							<b>Webservice Type</b> : REST<br/>
							<b>Url</b> : nomisma.org/closingDate?<br/>
							<b>Parameters</b> : identifiers(coin type URIs divided by a pipe '|')<br/>
							<b>Result</b> : returns an integer which represents the year. Negative numbers refer to B.C. dates.<br/>
							<b>Examples</b>: <a href="apis/closingDate?identifiers=http://nomisma.org/id/rrc-385.4|http://nomisma.org/id/rrc-409.2|http://numismatics.org/ocre/id/ric.1(2).aug.1a"
								>http://nomisma.org/apis/closingDate?identifiers=http://nomisma.org/id/rrc-385.4|http://nomisma.org/id/rrc-409.2|http://numismatics.org/ocre/id/ric.1(2).aug.1a</a>
						</p>
					</div>
					<div>
						<a name="getLabel"/>
						<h2>Get Label</h2>
						<p>Get the label of a Nomisma ID given its URI and language code.<br/>
							<b>Webservice Type</b> : REST<br/>
							<b>Url</b> : nomisma.org/getLabel?<br/>
							<b>Parameters</b> : uri (of Nomisma ID), lang (two-letter ISO language code)<br/>
							<b>Result</b> : returns the label in given language, or English as default.<br/>
							<b>Examples</b>: <a href="apis/getLabel?uri=http://nomisma.org/id/ar&amp;lang=fr">apis/getLabel?uri=http://nomisma.org/id/ar&amp;lang=fr</a>
						</p>
					</div>
				</div>

				<!-- footer -->
				<xsl:call-template name="footer"/>

			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
