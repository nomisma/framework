<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date modified: April 2022
	Function: Serialize SPARQL CONSTRUCT for datasets into a more useful interface -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:void="http://rdfs.org/ns/void#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: Datasets</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<script type="text/javascript" src="https://code.jquery.com/jquery-latest.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/result_functions.js"/>
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
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

					<h1>Datasets</h1>

					<p>Numismatic datasets have been aggregated from a wide variety of sources, listed below. They are generally categorized below:</p>
					
					<ul>
						<li>
							<a href="#NumismaticObject">Numismatic Objects</a>
						</li>
						<li>
							<a href="#TypeSeriesItem">Coin Types</a>
						</li>
						<li>
							<a href="#Hoard">Hoards</a>
						</li>
						<li>
							<a href="#Monogram">Monograms</a>
						</li>
						<li>
							<a href="#E28_Conceptual_Object">Dies</a>
						</li>						
					</ul>
					
					<ul class="list-inline">
						<li>
							<strong>Download datset list: </strong>
						</li>
						<li>
							<a href="./query?query={encode-for-uri(doc('input:query'))}&amp;output=xml">RDF/XML</a>
						</li>
						<li>
							<a href="./query?query={encode-for-uri(doc('input:query'))}&amp;output=text">Turtle</a>
						</li>
						<li>
							<a href="./query?query={encode-for-uri(doc('input:query'))}&amp;output=json">JSON-LD</a>
						</li>						
					</ul>

					<xsl:choose>
						<xsl:when test="count(descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset']) &gt; 0">
							<!-- separate datasets into categories -->
							<xsl:if
								test="descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset']/dcterms:type[@rdf:resource = 'http://nomisma.org/ontology#NumismaticObject']">
								<h2 id="NumismaticObject">Numismatic Objects (Coins, Medals, etc.)</h2>

								<div class="table-responsive">
									<table class="table table-striped">
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
											<xsl:apply-templates
												select="descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset'][dcterms:type[@rdf:resource = 'http://nomisma.org/ontology#NumismaticObject']]">
												<!--<xsl:sort select="dcterms:publisher[1]"/>-->
												<xsl:sort select="dcterms:publisher[1]" order="ascending" data-type="text"/>
												<xsl:sort select="dcterms:title[1]" order="ascending" data-type="text"/>

												<xsl:with-param name="type">http://nomisma.org/ontology#NumismaticObject</xsl:with-param>
											</xsl:apply-templates>
										</tbody>
									</table>
								</div>
							</xsl:if>

							<xsl:if
								test="descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset']/dcterms:type[@rdf:resource = 'http://nomisma.org/ontology#TypeSeriesItem']">
								<h2 id="TypeSeriesItem">Coin Types</h2>
								<p>Note that the data downloads may also include RDF for symbols and monograms.</p>
								<div class="table-responsive">
									<table class="table table-striped">
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
											<xsl:apply-templates
												select="descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset'][dcterms:type[@rdf:resource = 'http://nomisma.org/ontology#TypeSeriesItem']]">
												<!--<xsl:sort select="dcterms:publisher[1]"/>-->
												<xsl:sort select="dcterms:publisher[1]" order="ascending" data-type="text"/>
												<xsl:sort select="dcterms:title[1]" order="ascending" data-type="text"/>

												<xsl:with-param name="type">http://nomisma.org/ontology#TypeSeriesItem</xsl:with-param>
											</xsl:apply-templates>
										</tbody>
									</table>
								</div>
							</xsl:if>
							
							<xsl:if
								test="descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset']/dcterms:type[@rdf:resource = 'http://nomisma.org/ontology#Hoard']">
								<h2 id="Hoard">Hoards</h2>								
								<div class="table-responsive">
									<table class="table table-striped">
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
											<xsl:apply-templates
												select="descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset'][dcterms:type[@rdf:resource = 'http://nomisma.org/ontology#Hoard']]">
												<!--<xsl:sort select="dcterms:publisher[1]"/>-->
												<xsl:sort select="dcterms:publisher[1]" order="ascending" data-type="text"/>
												<xsl:sort select="dcterms:title[1]" order="ascending" data-type="text"/>
												
												<xsl:with-param name="type">http://nomisma.org/ontology#Hoard</xsl:with-param>
											</xsl:apply-templates>
										</tbody>
									</table>
								</div>
							</xsl:if>

							<xsl:if
								test="descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset']/dcterms:type[@rdf:resource = 'http://nomisma.org/ontology#Monogram' or @rdf:resource = 'http://www.cidoc-crm.org/cidoc-crm/E37_Mark']">
								<h2 id="Monogram">Monograms</h2>
								<p>Note that the data downloads may also include RDF for coin types.</p>
								<div class="table-responsive">
									<table class="table table-striped">
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
											<xsl:apply-templates
												select="descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset'][dcterms:type[@rdf:resource = 'http://nomisma.org/ontology#Monogram' or @rdf:resource = 'http://www.cidoc-crm.org/cidoc-crm/E37_Mark']]">
												<!--<xsl:sort select="dcterms:publisher[1]"/>-->
												<xsl:sort select="dcterms:publisher[1]" order="ascending" data-type="text"/>
												<xsl:sort select="dcterms:title[1]" order="ascending" data-type="text"/>
												
												<xsl:with-param name="type">http://nomisma.org/ontology#Monogram</xsl:with-param>
											</xsl:apply-templates>
										</tbody>
									</table>
								</div>
							</xsl:if>
							
							<xsl:if
								test="descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset']/dcterms:type[@rdf:resource = 'http://nomisma.org/ontology#Monogram' or @rdf:resource = 'http://www.cidoc-crm.org/cidoc-crm/E37_Mark']">
								<h2 id="E28_Conceptual_Object">Dies</h2>
								
								<div class="table-responsive">
									<table class="table table-striped">
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
											<xsl:apply-templates
												select="descendant::*[local-name() = 'Dataset' or rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset'][dcterms:type[@rdf:resource = 'http://www.cidoc-crm.org/cidoc-crm/E28_Conceptual_Object']]">
												<!--<xsl:sort select="dcterms:publisher[1]"/>-->
												<xsl:sort select="dcterms:publisher[1]" order="ascending" data-type="text"/>
												<xsl:sort select="dcterms:title[1]" order="ascending" data-type="text"/>
												
												<xsl:with-param name="type">http://www.cidoc-crm.org/cidoc-crm/E28_Conceptual_Object</xsl:with-param>
											</xsl:apply-templates>
										</tbody>
									</table>
								</div>
							</xsl:if>

						</xsl:when>
						<xsl:otherwise>
							<p>No datasets available in the SPARQL endpoint.</p>
						</xsl:otherwise>
					</xsl:choose>


				</div>
			</div>
		</div>
	</xsl:template>



	<xsl:template match="void:Dataset | rdf:Description[rdf:type/@rdf:resource = 'http://rdfs.org/ns/void#Dataset']">
		<xsl:param name="type"/>

		<tr>
			<td>
				<a href="{@rdf:about}">
					<xsl:value-of select="dcterms:title"/>
				</a>
			</td>
			<td>
				<xsl:value-of select="dcterms:description"/>
			</td>
			<td>
				<xsl:value-of select="dcterms:publisher"/>
			</td>
			<td class="text-center">
				<xsl:choose>
					<xsl:when test="dcterms:license">
						<xsl:apply-templates select="dcterms:license"/>
					</xsl:when>
					<xsl:when test="dcterms:rights">
						<xsl:apply-templates select="dcterms:rights"/>
					</xsl:when>
				</xsl:choose>
			</td>
			<td class="text-center">
				<xsl:variable name="counts" as="item()*">
					<!-- seems to repeat because of SPARQL CONSTRUCT issue in Fuseki? -->
					<xsl:for-each select="dcterms:hasPart">
						<xsl:variable name="id" select="@rdf:nodeID"/>

						<counts>
							<xsl:for-each select="//rdf:Description[@rdf:nodeID = $id][dcterms:type/@rdf:resource = $type]">
								<count>
									<xsl:value-of select="void:entities"/>
								</count>
							</xsl:for-each>
						</counts>
					</xsl:for-each>
				</xsl:variable>

				<xsl:value-of select="distinct-values($counts//count)"/>
			</td>
			<td class="text-center">
				<xsl:apply-templates select="void:dataDump"/>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="dcterms:license">
		<xsl:choose>
			<xsl:when test="@rdf:resource">
				<a href="{@rdf:resource}">
					<xsl:variable name="license" select="@rdf:resource"/>
					<xsl:choose>
						<xsl:when test="matches($license, '^https?://opendatacommons.org/licenses/odbl/')">ODC-ODbL</xsl:when>
						<xsl:when test="matches($license, '^https?://opendatacommons.org/licenses/by/')">ODC-by</xsl:when>
						<xsl:when test="matches($license, '^https?://opendatacommons.org/licenses/pddl/')">ODC-PDDL</xsl:when>
						<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by/')">
							<img src="https://i.creativecommons.org/l/by/3.0/88x31.png" alt="CC BY" title="CC BY"/>
						</xsl:when>
						<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by-nd/')">
							<img src="https://i.creativecommons.org/l/by-nd/3.0/88x31.png" alt="CC BY-ND" title="CC BY-ND"/>
						</xsl:when>
						<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by-nc-sa/')">
							<img src="https://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" alt="CC BY-NC-SA" title="CC BY-NC-SA"/>
						</xsl:when>
						<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by-sa/')">
							<img src="https://i.creativecommons.org/l/by-sa/3.0/88x31.png" alt="CC BY-SA" title="CC BY-SA"/>
						</xsl:when>
						<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by-nc/')">
							<img src="https://i.creativecommons.org/l/by-nc/3.0/88x31.png" alt="CC BY-NC" title="CC BY-NC"/>
						</xsl:when>
						<xsl:when test="matches($license, '^https?://creativecommons.org/licenses/by-nc-nd/')">
							<img src="https://i.creativecommons.org/l/by-nc-nd/3.0/88x31.png" alt="CC BY-NC-ND" title="CC BY-NC-ND"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@rdf:resource"/>
						</xsl:otherwise>
					</xsl:choose>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dcterms:rights">
		<xsl:choose>
			<xsl:when test="@rdf:resource">
				<a href="{@rdf:resource}">
					<xsl:value-of select="@rdf:resource"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="void:dataDump">
		<a href="{@rdf:resource}" title="{@rdf:resource}">
			<span class="glyphicon glyphicon-download-alt"/>
		</a>
	</xsl:template>


	<!--<xsl:template match="res:result">
		<xsl:param name="dumps"/>

		<tr>
			<td> </td>
			<td>
				<xsl:value-of select="res:binding[@name = 'description']/res:literal"/>
			</td>
			<td>
				<xsl:value-of select="res:binding[@name = 'publisher']/res:literal"/>
			</td>
			<td class="text-center">
				<!-\- display license first if available, otherwise rights -\->
				
			</td>
			<td class="text-center">
				<xsl:value-of select="res:binding[@name = 'count']/res:literal"/>
			</td>
			<td class="text-center">
				<xsl:for-each select="$dumps">
					<a href="{.}" title="{.}">
						<span class="glyphicon glyphicon-download-alt"/>
					</a>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>-->
</xsl:stylesheet>
