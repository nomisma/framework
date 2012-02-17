<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nm="http://nomisma.org/id/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:exsl="http://exslt.org/common"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:skos="http://www.w3.org/2008/05/skos#"
	xmlns:numishare="http://code.google.com/p/numishare/" xmlns:nuds="http://nomisma.org/id/nuds" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:gml="http://www.opengis.net/gml/"
	xmlns:nomisma="http://nomisma.org/id/" version="2.0">
	<xsl:output method="xhtml" encoding="UTF-8"/>

	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="display_path">../</xsl:variable>


	<xsl:template match="/">
		<xsl:variable name="id" select="tokenize(rdf:RDF/skos:Concept/@rdf:about, '/')[last()]"/>
		<xsl:variable name="type" select="tokenize(rdf:RDF/skos:Concept/skos:broader/@rdf:about, '/')[last()]"/>

		<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:batlas="http://atlantides.org/batlas/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:gml="http://www.opengis.net/gml/"
			xmlns:nm="http://nomisma.org/id/" xmlns:ov="http://open.vocab.org/terms/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2008/05/skos#">
			<head>
				<link rel="x-pelagios-oac-serialization" title="Pelagios compatible version" type="application/rdf+xml" href="http://nomisma.org/nomisma.org.pelagios.rdf"/>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
				<title>http://nomisma.org/id/<xsl:value-of select="$id"/></title>
				<base href="http://nomisma.org/id/"/>

				<link rel="alternate" type="application/rdf+xml"
					href="http://www.w3.org/2007/08/pyRdfa/extract?uri={encode-for-uri(concat('http://admin.numismatics.org:8080/orbeon/nomisma/id/', $id))}"/>

				<link type="application/vnd.google-earth.kml+xml" href="http://nomisma.org/kml/{$id}.kml"/>
				<link type="application/vnd.google-earth.kml+xml" href="http://nomisma.org/kml/{$id}-all.kml"/>

				<!-- styling -->
				<link rel="stylesheet" type="text/css" href="{$display_path}/css/grids-min.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}/css/reset-fonts-grids.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}/css/base-min.css"/>
				<link rel="stylesheet" type="text/css" href="{$display_path}/css/fonts-min.css"/>

				<!-- nomisma styling -->
				<link rel="stylesheet" href="{$display_path}/css/style.css"/>

				<!-- javascript -->
				<xsl:if test="contains($type, 'hoard') or contains($type, 'type_series_item') or contains($type, 'mint')">
					<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
					<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
					<script type="text/javascript" src="{$display_path}/javascript/jquery-1.6.1.min.js"/>
					<script type="text/javascript" src="{$display_path}/javascript/map_functions.js"/>
					<script type="text/javascript">
					$(document).ready(function(){
						initialize_map('<xsl:value-of select="$id"/>');
					});
				</script>
				</xsl:if>

			</head>
			<body class="yui-skin-sam">
				<div id="doc4">
					<div id="hd">
						<h1>header</h1> insert menu here: <span style="float:right"><a href="{$display_path}admin/edit/?id={$id}">edit id</a></span>
					</div>
					<div id="bd">
						<div id="yui-main">
							<div class="yui-b">
								<div class="yui-g">
									<div class="yui-u first">
										<xsl:apply-templates select="/rdf:RDF/skos:Concept"/>
									</div>
									<div class="yui-u">
										<div id="map"/>
									</div>
								</div>
							</div>
						</div>

					</div>
					<div id="ft">
						<div class="center">
							<a rel="license" href="http://creativecommons.org/licenses/by-nc/3.0/"><img alt="Creative Commons License" style="border-width:0"
									src="http://i.creativecommons.org/l/by-nc/3.0/88x31.png"/></a><br/><span xmlns:dc="http://purl.org/dc/elements/1.1/" property="dc:title">Nomisma.org</span> by <a
								xmlns:cc="http://creativecommons.org/ns#" href="http://nomisma.org" property="cc:attributionName" rel="cc:attributionURL">http://nomisma.org</a> is licensed under a <a
								rel="license" href="http://creativecommons.org/licenses/by-nc/3.0/">Creative Commons Attribution-Noncommercial 3.0 License</a>. </div>
						<div class="center">
							<span style="color:gray">All data in nomisma.org is preliminary and in the process of being updated.</span>
						</div>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="skos:Concept">
		<div>
			<h1>
				<xsl:apply-templates select="skos:prefLabel[@xml:lang='en']"/>
				<xsl:text> (</xsl:text>
				<a href="{skos:broader/@rdf:about}">
					<xsl:value-of select="substring-after(skos:broader/@rdf:about, 'id/')"/>
				</a>
				<xsl:text>)</xsl:text>
			</h1>
			<xsl:choose>
				<xsl:when test="contains(skos:broader/@rdf:about, 'type_series_item')">
					<xsl:variable name="object">
						<xsl:copy-of select="document(skos:definition/@rdf:resource)/*[local-name()='nuds']"/>
					</xsl:variable>
					<h3>Typological Attributes</h3>
					<xsl:apply-templates select="exsl:node-set($object)//*[local-name()='typeDesc']"/>
				</xsl:when>
				<xsl:when test="contains(skos:broader/@rdf:about, 'hoard')"> hoard </xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="skos:definition"/>
					<xsl:if test="count(skos:altLabel) &gt; 0">
						<h3>Alternate Labels</h3>
						<dl>
							<xsl:apply-templates select="skos:altLabel"/>
						</dl>
					</xsl:if>
					<xsl:if test="count(skos:related) &gt; 0">
						<h3>Related Resources</h3>
						<dl>
							<xsl:apply-templates select="skos:related"/>
						</dl>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template match="skos:prefLabel">
		<span>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}" select="."/>
			</xsl:for-each>
			<xsl:value-of select="."/>
		</span>
	</xsl:template>

	<xsl:template match="skos:definition">
		<p>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}" select="."/>
			</xsl:for-each>
			<xsl:value-of select="."/>
		</p>
	</xsl:template>

	<xsl:template match="skos:altLabel">
		<dt>
			<xsl:value-of select="nomisma:normalize-language(@xml:lang)"/>
		</dt>
		<dd>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name()}" select="."/>
			</xsl:for-each>
			<xsl:value-of select="."/>
		</dd>
	</xsl:template>

	<xsl:template match="skos:related">
		<dt>
			<xsl:value-of select="nomisma:normalize-href(@rdf:resource)"/>
		</dt>
		<dd>
			<a href="{@rdf:resource}">
				<xsl:value-of select="@rdf:resource"/>
			</a>
		</dd>
	</xsl:template>

	<!-- ****************** COIN-TYPE AND HOARD TEMPLATES **************************** -->
	<xsl:template match="*[local-name()='typeDesc']">
		<ul>
			<xsl:apply-templates mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="*" mode="descMeta">
		<xsl:choose>
			<xsl:when test="not(child::*)">
				<!-- the facet field is the @xlink:role if it exists, otherwise it is the name of the nuds element -->
				<xsl:variable name="field">
					<xsl:choose>
						<xsl:when test="string(@xlink:role)">
							<xsl:value-of select="@xlink:role"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local-name()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<li>
					<b>
						<xsl:choose>
							<xsl:when test="string(@xlink:role)">
								<xsl:value-of select="concat(upper-case(substring(@xlink:role, 1, 1)), substring(@xlink:role, 2))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="numishare:regularize_node(local-name())"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>: </xsl:text>
					</b>

					<xsl:value-of select="."/>

					<!-- display title -->
					<xsl:if test="string(@title)">
						<xsl:text> (</xsl:text>
						<xsl:value-of select="@title"/>
						<xsl:text>)</xsl:text>
					</xsl:if>

					<!-- create links to resources -->
					<xsl:if test="string(@xlink:href)">
						<xsl:variable name="href" select="@xlink:href"/>

						<a href="{$href}" target="_blank" title="{if (contains($href, 'geonames')) then 'geonames' else if (contains($href, 'nomisma')) then 'nomisma' else ''}">
							<img src="{$display_path}images/external.png" alt="external link" class="external_link"/>

						</a>
						<!-- parse nomisma RDFa, create links for pleiades and wikipedia -->
						<xsl:if test="contains($href, 'nomisma.org')">
							<xsl:variable name="rdf_url" select="concat('http://nomisma.org/cgi-bin/RDFa.py?uri=', encode-for-uri($href))"/>
							<xsl:for-each select="document($rdf_url)//skos:related">
								<xsl:variable name="source">
									<xsl:choose>
										<xsl:when test="contains(@rdf:resource, 'pleiades')">
											<xsl:text>pleiades</xsl:text>
										</xsl:when>
										<xsl:when test="contains(@rdf:resource, 'wikipedia')">
											<xsl:text>wikipedia</xsl:text>
										</xsl:when>
									</xsl:choose>
								</xsl:variable>

								<a href="{@rdf:resource}" target="_blank" title="{$source}">
									<img src="{$display_path}images/{$source}.png" alt="external link" class="external_link"/>
								</a>
							</xsl:for-each>
						</xsl:if>
					</xsl:if>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li>
					<xsl:choose>
						<xsl:when test="parent::physDesc">
							<h3>
								<xsl:value-of select="numishare:regularize_node(local-name())"/>
							</h3>
						</xsl:when>
						<xsl:otherwise>
							<h4>
								<xsl:value-of select="numishare:regularize_node(local-name())"/>
							</h4>
						</xsl:otherwise>
					</xsl:choose>
					<ul>
						<xsl:apply-templates select="*" mode="descMeta"/>
					</ul>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ***************** FUNCTIONS ******************* -->
	<xsl:function name="numishare:regularize_node">
		<xsl:param name="name"/>
		<xsl:choose>
			<xsl:when test="$name='acknowledgment'">Acknowledgment</xsl:when>
			<xsl:when test="$name='acqinfo'">Aquisitition Information</xsl:when>
			<xsl:when test="$name='acquiredFrom'">Acquired From</xsl:when>
			<xsl:when test="$name='appraisal'">Appraisal</xsl:when>
			<xsl:when test="$name='appraiser'">Appraiser</xsl:when>
			<xsl:when test="$name='authority'">Authority</xsl:when>
			<xsl:when test="$name='axis'">Axis</xsl:when>
			<xsl:when test="$name='collection'">Collection</xsl:when>
			<xsl:when test="$name='completeness'">Completeness</xsl:when>
			<xsl:when test="$name='condition'">Condition</xsl:when>
			<xsl:when test="$name='conservationState'">Conservation State</xsl:when>
			<xsl:when test="$name='coordinates'">Coordinates</xsl:when>
			<xsl:when test="$name='countermark'">Countermark</xsl:when>
			<xsl:when test="$name='custodhist'">Custodial History</xsl:when>
			<xsl:when test="$name='date'">Date</xsl:when>
			<xsl:when test="$name='dateOnObject'">Date on Object</xsl:when>
			<xsl:when test="$name='denomination'">Denomination</xsl:when>
			<xsl:when test="$name='department'">Department</xsl:when>
			<xsl:when test="$name='deposit'">Deposit</xsl:when>
			<xsl:when test="$name='description'">Description</xsl:when>
			<xsl:when test="$name='diameter'">Diameter</xsl:when>
			<xsl:when test="$name='discovery'">Discovery</xsl:when>
			<xsl:when test="$name='disposition'">Disposition</xsl:when>
			<xsl:when test="$name='edge'">Edge</xsl:when>
			<xsl:when test="$name='era'">Era</xsl:when>
			<xsl:when test="$name='finder'">Finder</xsl:when>
			<xsl:when test="$name='findspot'">Findspot</xsl:when>
			<xsl:when test="$name='geographic'">Geographic</xsl:when>
			<xsl:when test="$name='grade'">Grade</xsl:when>
			<xsl:when test="$name='height'">Height</xsl:when>
			<xsl:when test="$name='identifier'">Identifier</xsl:when>
			<xsl:when test="$name='landowner'">Landowner</xsl:when>
			<xsl:when test="$name='legend'">Legend</xsl:when>
			<xsl:when test="$name='material'">Material</xsl:when>
			<xsl:when test="$name='measurementsSet'">Measurements</xsl:when>
			<xsl:when test="$name='note'">Note</xsl:when>
			<xsl:when test="$name='objectType'">Object Type</xsl:when>
			<xsl:when test="$name='obverse'">Obverse</xsl:when>
			<xsl:when test="$name='owner'">Owner</xsl:when>
			<xsl:when test="$name='private'">Private</xsl:when>
			<xsl:when test="$name='public'">Public</xsl:when>
			<xsl:when test="$name='reference'">Reference</xsl:when>
			<xsl:when test="$name='repository'">Repository</xsl:when>
			<xsl:when test="$name='reverse'">Reverse</xsl:when>
			<xsl:when test="$name='saleCatalog'">Sale Catalog</xsl:when>
			<xsl:when test="$name='saleItem'">Sale Item</xsl:when>
			<xsl:when test="$name='salePrice'">Sale Price</xsl:when>
			<xsl:when test="$name='shape'">Shape</xsl:when>
			<xsl:when test="$name='symbol'">Symbol</xsl:when>
			<xsl:when test="$name='testmark'">Test Mark</xsl:when>
			<xsl:when test="$name='title'">Title</xsl:when>
			<xsl:when test="$name='type'">Type</xsl:when>
			<xsl:when test="$name='thickness'">Thickness</xsl:when>
			<xsl:when test="$name='wear'">Wear</xsl:when>
			<xsl:when test="$name='weight'">Weight</xsl:when>
			<xsl:when test="$name='width'">Width</xsl:when>
			<xsl:otherwise>Unlabeled Category</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="nomisma:normalize-language">
		<xsl:param name="lang"/>

		<xsl:choose>
			<xsl:when test="$lang='de'">German</xsl:when>
			<xsl:when test="$lang='en'">English</xsl:when>
			<xsl:when test="$lang='fr'">French</xsl:when>
			<xsl:when test="$lang='it'">Italian</xsl:when>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="nomisma:normalize-href">
		<xsl:param name="href"/>

		<xsl:choose>
			<xsl:when test="contains($href, 'pleiades')">Pleiades</xsl:when>
			<xsl:when test="contains($href, 'wikipedia')">Wikipedia</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="tokenize(substring-after($href, 'http://'), '/')[1]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
