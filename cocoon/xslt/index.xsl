<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="templates.xsl"/>

	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml"
			prefix="nm: http://nomisma.org/id/
			dcterms: http://purl.org/dc/terms/
			foaf: http://xmlns.com/foaf/0.1/
			geo:  http://www.w3.org/2003/01/geo/wgs84_pos#
			owl:  http://www.w3.org/2002/07/owl#
			rdfs: http://www.w3.org/2000/01/rdf-schema#
			rdfa: http://www.w3.org/ns/rdfa#
			rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
			skos: http://www.w3.org/2004/02/skos/core#"
			vocab="http://nomisma.org/id/">
			<head>
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/>
				<title>Nomisma</title>
				<style type="text/css">
					@import url(<xsl:value-of select="concat($display_path, 'style.css')"/>
					);</style>
				<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"/>
			</head>
			<body>
				<xsl:call-template name="header"/>

				<div class="center">
					<h3>
						<a name="Introduction" id="Introduction">Introduction</a>
					</h3>
					<div class="level3">

						<p>Nomisma.org is a collaborative project to provide stable digital representations of numismatic concepts according to the principles
							of <a href="http://www.w3.org/DesignIssues/LinkedData.html">Linked Open Data</a>. These take the form of http URIs that also provide
							access to reusable information about those concepts, along with links to other resources. The base format of nomisma.org is
							xhtml+rdfa1.1, with versions available in multiple formats.</p>

						<p>While the URIs provided by nomisma.org are stable, the project is in progress and subject to constant expansion and ongoing
							correction. This is particularly the case for the information provided about each nomisma.org identifier.</p>

						<p>The information provided by nomisma.org has been provided by a wide community of scholars and insitutions. Click here for a current
							list.</p>

						<p>The project is steered by a committee currently consisting of:</p>


						<ul>
							<li>Sebastian Heath, <a href="http://isaw.nyu.edu/">NYU ISAW</a></li>
							<li>Andrew Meadows, <a href="http://numismatics.org">ANS</a></li>
							<li>Daniel Pett, <a href="http://finds.org.uk/">BM PAS</a></li>
							<li>David Wigg-Wolf, <a href="http://www.dainst.org/en/department/rgk">DAI RGK</a></li>
						</ul>

						<p>Implementation is by:</p>

						<ul>
							<li>Ethan Gruber, <a href="http://numismatics.org">ANS</a></li>
							<li>Sebastian Heath, <a href="http://isaw.nyu.edu/">NYU ISAW</a></li>
						</ul>

						<p>Nomisma.org also hosts the <a href="http://nomisma.org/nuds/numismatic_database_standard">Numismatic Description Standard</a></p>
					</div>
				</div>

				<div class="center">
					<h3>Contributors</h3>
					<p>The following institutions have contributed data, specialist advice and/or financial support to the Nomisma project:</p>
					<div>
						<div class="media">
							<a href="http://numismatics.org" title="http://numismatics.org" rel="nofollow">
								<img src="http://www.numismatics.org/pmwiki/pub/skins/ans/ans_seal.gif" alt="http://numismatics.org"/>
							</a>
						</div>
						<div class="media">
							<a href="http://www.paris-sorbonne.fr/" title="http://www.paris-sorbonne.fr/" rel="nofollow">
								<img src="http://nomisma.org/images/paris-small.jpg" alt="http://www.paris-sorbonne.fr/"/>
							</a>
						</div>
						<div class="media">
							<a href="http://stanford.edu" title="http://stanford.edu" rel="nofollow">
								<img src="http://nomisma.org/images/stanford-small.jpg" alt="http://stanford.edu"/>
							</a>
						</div>
						<!--<a href="http://www.jisc.ac.uk" class="media" title="http://www.jisc.ac.uk" rel="nofollow">
						<img src="http://www.jisc.ac.uk/media/3/4/5/%7B345F1B7F-4AD6-4A61-B5BE-70AFA60F002F%7Djisclogojpgweb.jpg" />
						</a>-->
						<div class="media">
							<a href="http://www.ahrc.ac.uk/" title="http://www.ahrc.ac.uk/" rel="nofollow">
								<img src="http://archaeologydataservice.ac.uk/images/logos/org34.png" alt="http://www.ahrc.ac.uk/"/>
							</a>
						</div>
						<div class="media">
							<a href="http://www.smb.museum/ikmk/" title="http://www.smb.museum/ikmk/" rel="nofollow">
								<img src="http://nomisma.org/images/SMB_MK_Black_sRGB.jpg" alt="http://www.smb.museum/ikmk/"/>
							</a>
						</div>
						<div class="media">
							<a href="http://www.acad.ro/" title="http://www.acad.ro/" rel="nofollow">
								<img src="http://upload.wikimedia.org/wikipedia/de/7/7a/Sigla_academia_romana.gif" alt="http://www.acad.ro/"/>
							</a>
						</div>
					</div>
				</div>

				<div class="center">
					<h3>Data Download</h3>
					<a href="nomisma.org.xml">XHTML+RDFa</a>
				</div>
				<!-- footer -->
				<xsl:call-template name="footer"/>

			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
