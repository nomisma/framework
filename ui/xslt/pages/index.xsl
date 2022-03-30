<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:variable name="display_path">./</xsl:variable>

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
				<div class="col-md-8">
					<h1>Nomisma</h1>
					<xsl:copy-of select="/content/content/index/*"/>
				</div>
				<div class="col-md-4">
					<div>
						<h3>Data Export</h3>
						<div>
							<h4>Nomisma Linked Data</h4>
							<table class="table-dl">
								<tr>
									<td class="media">
										<img src="{$display_path}ui/images/nomisma-round.svg"/>
									</td>
									<td>
										<strong>Linked Data: </strong>
										<a href="nomisma.org.jsonld">JSON-LD</a>, <a href="nomisma.org.ttl">TTL</a>, <a href="nomisma.org.rdf">RDF/XML</a>
									</td>
								</tr>
							</table>
						</div>
						<div>
							<h4>Pelagios Annotations</h4>
							<table class="table-dl">
								<tr>
									<td class="media">
										<a href="http://commons.pelagios.org/">
											<img src="{$display_path}ui/images/pelagios.png"/>
										</a>
									</td>
									<td>
										<strong>VoID for Concepts: </strong>
										<a href="pelagios.void.rdf">RDF/XML</a>
										<br/>
										<strong>VoID for Partner Objects: </strong>
										<a href="pelagios-objects.void.rdf">RDF/XML</a>
									</td>
								</tr>
							</table>
						</div>
					</div>
					<div>
						<h3>Atom Feed</h3>
						<table class="table-dl">
							<tr>
								<td class="media">
									<a href="feed/">
										<img src="{$display_path}ui/images/atom-large.png"/>
									</a>
								</td>
								<td>
									<a href="feed/">Feed</a>
									<br/>
									<a href="http://numishare.blogspot.com/2013/07/updates-to-nomisma-atom-feed.html">Documentation</a>
								</td>
							</tr>
						</table>
					</div>
					<div>
						<h3>Contributors</h3>
						<p>The following institutions have contributed data, specialist advice and/or financial support to the Nomisma project:</p>

						<div class="media">
							<a href="http://numismatics.org" title="http://numismatics.org" rel="nofollow">
								<img src="https://nomisma.org/ui/images/ans_large.png" alt="http://numismatics.org"/>
							</a>
						</div>
						<div class="media">
							<a href="http://www.paris-sorbonne.fr/" title="http://www.paris-sorbonne.fr/" rel="nofollow">
								<img src="ui/images/paris-small.jpg" alt="http://www.paris-sorbonne.fr/"/>
							</a>
						</div>
						<!--<div class="media">
							<a href="http://stanford.edu" title="http://stanford.edu" rel="nofollow">
								<img src="ui/images/stanford-small.jpg" alt="http://stanford.edu"/>
							</a>
						</div>-->
						<!--<a href="http://www.jisc.ac.uk" class="media" title="http://www.jisc.ac.uk" rel="nofollow">
								<img src="http://www.jisc.ac.uk/media/3/4/5/%7B345F1B7F-4AD6-4A61-B5BE-70AFA60F002F%7Djisclogojpgweb.jpg" />
								</a>-->
						<div class="media">
							<a href="http://finds.org.uk/" title="http://finds.org.uk/" rel="nofollow">
								<img src="https://finds.org.uk/images/logos/pas.gif" alt="http://finds.org.uk/"/>
							</a>
						</div>
						<div class="media">
							<a href="http://www.britishmuseum.org/" title="http://www.britishmuseum.org/" rel="nofollow">
								<img src="https://finds.org.uk/images/logos/bm_logo.png" alt="http://www.britishmuseum.org/"/>
							</a>
						</div>
						<div class="media">
							<a href="http://www.dainst.org/" title="http://www.dainst.org/" rel="nofollow">
								<img src="ui/images/GreifBlau.jpg" alt="http://www.dainst.org/"/>
							</a>
						</div>
						<div class="media">
							<a href="http://www.ahrc.ac.uk/" title="http://www.ahrc.ac.uk/" rel="nofollow">
								<img src="https://archaeologydataservice.ac.uk/images/logos/org34.png" alt="http://www.ahrc.ac.uk/"/>
							</a>
						</div>
						<div class="media">
							<a href="http://www.smb.museum/ikmk/" title="http://www.smb.museum/ikmk/" rel="nofollow">
								<img src="ui/images/SMB_MK_Black_sRGB.jpg" alt="http://www.smb.museum/ikmk/"/>
							</a>
						</div>
						<!--<div class="media">
							<a href="http://www.acad.ro/" title="http://www.acad.ro/" rel="nofollow">
								<img src="http://upload.wikimedia.org/wikipedia/de/7/7a/Sigla_academia_romana.gif" alt="http://www.acad.ro/"/>
							</a>
						</div>-->
						<div class="media">
							<a href="http://www2.uni-frankfurt.de/" title="http://www2.uni-frankfurt.de/" rel="nofollow">
								<img src="ui/images/goethe.png" alt="http://www2.uni-frankfurt.de/"/>
							</a>
						</div>
						<div class="media">
							<a href="https://www.humboldt-foundation.de/" title="https://www.humboldt-foundation.de/" rel="nofollow">
								<img src="ui/images/AvH_Logo_n7_Word_rgb2.jpg" alt="https://www.humboldt-foundation.de/"/>
							</a>
						</div>
						<div class="media">
							<a href="https://www.neh.gov/" title="The National Endowment for the Humanities" rel="nofollow">
								<img src="ui/images/neh_logo_horizontal_rgb.jpg" alt="NEH Logo"/>
							</a>
						</div>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
