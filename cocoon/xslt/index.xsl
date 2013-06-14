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
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
				<title>Nomisma</title>
				<style type="text/css">
					@import url(<xsl:value-of select="concat($display_path, 'style.css')"/>);
				</style>
				<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
			</head>
			<body>
				<xsl:call-template name="header"/>
				
				<div class='center'>
					<p>
						
						<code>Nomsima is undergoing maintenance/upgrade so things may be a little odd for a bit</code>
					</p>
					
					
					
					<h3><a name="Introduction" id="Introduction">Introduction</a></h3>
					<div class="level3">
						
						<p>
							
							Nomisma.org is a collaborative effort to provide stable digital representations of numismatic concepts and entities, for example the generic idea of a <a href="/id/hoard" class="wikilink1" title="id:hoard">coin hoard</a> or an actual hoard as documented in the print publication <em><a href="/id/igch" class="wikilink1" title="id:igch">An Inventory of Greek Coin Hoards</a></em> (IGCH). Nomisma.org provides a short, often recognizable, <acronym title="Uniform Resource Identifier">URI</acronym> for each resource it defines and presents the related information in both human and machine readable form. Creators of digital content can use these stable URIs to build a web of linked knowledge that enables faster acquisition and analysis of well-structured numismatic data.
						</p>
						
						<p>
							Example URIs are:
						</p>
						<ul>
							<li class="level1"><div class="li"> <a href="id/axis" class="urlextern" title="http://nomisma.org/id/axis"  rel="nofollow">http://nomisma.org/id/axis</a></div>
							</li>
							<li class="level1"><div class="li"> <a href="id/hoard" class="urlextern" title="http://nomisma.org/id/hoard"  rel="nofollow">http://nomisma.org/id/hoard</a></div>
							</li>
							<li class="level1"><div class="li"> <a href="id/igch0262" class="urlextern" title="http://nomisma.org/id/igch0262"  rel="nofollow">http://nomisma.org/id/igch0262</a> (with links to CNG and preliminary map of findspot and mints)</div>
							</li>
							<li class="level1"><div class="li"> <a href="id/igch1240" class="urlextern" title="http://nomisma.org/id/igch1240"  rel="nofollow">http://nomisma.org/id/igch1240</a> (with links to SNG and map of findspot and mints)</div>
							</li>
							<li class="level1"><div class="li"> <a href="id/igch2122" class="urlextern" title="http://nomisma.org/id/igch2122"  rel="nofollow">http://nomisma.org/id/igch2122</a> (with links to ANS collection)</div>
							</li>
							<li class="level1"><div class="li"> <a href="id/igch1546" class="urlextern" title="http://nomisma.org/id/igch1546"  rel="nofollow">http://nomisma.org/id/igch1546</a> (with links to ANS and Yale collections)</div>
							</li>
							<li class="level1"><div class="li"> <a href="id/igch2130" class="urlextern" title="http://nomisma.org/id/igch2130"  rel="nofollow">http://nomisma.org/id/igch2130</a></div>
							</li>
						</ul>
						
						<p>
							
							See list of <a href="http://nomisma.org/?idx=id" class="urlextern" title="http://nomisma.org/?idx=id"  rel="nofollow">all</a> id&#039;s assigned to date.
						</p>
						
						<p>
							The current data has been contributed by researchers at the American Numismatic Society, British Museum, The University of Paris-Sorbonne <a href="http://www.nomisma.paris-sorbonne.fr/" class="urlextern" title="http://www.nomisma.paris-sorbonne.fr/"  rel="nofollow">Nomisma project</a>, Yale University Art Gallery. Hosting for Nomisma is provided by the <a href="http://numismatics.org" class="urlextern" title="http://numismatics.org"  rel="nofollow">The American Numismatic Society</a>. The following organizations have contributed financial support and/or data.
						</p>
						
						<p>
								<a href="http://numismatics.org" class="media" title="http://numismatics.org"  rel="nofollow"><img src="http://www.numismatics.org/pmwiki/pub/skins/ans/ans_seal.gif" class="media" alt="" /></a>
							<a href="http://www.paris-sorbonne.fr/" class="media" title="http://www.paris-sorbonne.fr/"  rel="nofollow"><img src="http://nomisma.org/images/paris-small.jpg" class="media" title="paris-small.jpg" alt="paris-small.jpg" /></a> 
							<a href="http://stanford.edu" class="media" title="http://stanford.edu"  rel="nofollow"><img src="http://nomisma.org/images/stanford-small.jpg" class="media" title="stanford-small.jpg" alt="stanford-small.jpg" /></a>
							<a href="http://www.jisc.ac.uk" class="media" title="http://www.jisc.ac.uk"  rel="nofollow"><img src="http://www.jisc.ac.uk/media/3/4/5/%7B345F1B7F-4AD6-4A61-B5BE-70AFA60F002F%7Djisclogojpgweb.jpg" class="media" title="7B345F1B7F-4AD6-4A61-B5BE-70AFA60F002F_7Djisclogojpgweb.jpg" alt="7B345F1B7F-4AD6-4A61-B5BE-70AFA60F002F_7Djisclogojpgweb.jpg" /></a>
							<a href="http://www.ahrc.ac.uk/" class="media" title="http://www.ahrc.ac.uk/"  rel="nofollow"><img src="http://archaeologydataservice.ac.uk/images/logos/org34.png" class="media" alt="" /></a>
							<a href="http://www.smb.museum/ikmk/" class="media" title="http://www.smb.museum/ikmk/"  rel="nofollow"><img src="http://nomisma.org/images/SMB_MK_Black_sRGB.jpg" class="media" title="SMB_MK_Black_sRGB.jpg" alt="SMB_MK_Black_sRGB.jpg" /></a> 
							<a href="http://www.acad.ro/" class="media" title="http://www.acad.ro/"  rel="nofollow"><img src="http://upload.wikimedia.org/wikipedia/de/7/7a/Sigla_academia_romana.gif" class="media" alt="" /></a>
						</p>
						
					</div>
					
					<h3><a name="Digital_IGCH" id="Digital_IGCH">Digital IGCH</a></h3>
					<div class="level3">
						
						<p>
							As a test case, Nomisma.org is developing a digital version of IGCH. All 2387 hoards have been assigned stable URIs and the text from the original publication is online. IGCH is a good dataset with which to explore the potential of nomisma.org because its stable entities, hoards as identified by a unique number, are well known within the field of ancient numismatics. <a href="id/igch0156" class="urlextern" title="http://nomisma.org/id/igch0156"  rel="nofollow">http://nomisma.org/id/igch0156</a> is recognizable and its semantics are clear: a digital representation of the entity commonly abbreviated as IGCH 156. Furthermore, hoards are usefully conceived of as a set of links to other numismatic entities, with the mints of the coins within each hoard and its findspot being of obvious interest. Nomisma.org will define conventions for identifying the numismatic information inherent within hoards and for turning this information into explicit links. Following the digital publication of IGCH, Nomisma.org will integrate data from the ongoing <i>Coin Hoards</i> series, which will result in information for approximately 4500 hoards being available.
						</p>
						
						<p>
							Map of the 2nd Century BC hoard <a href="id/igch1544" class="urlextern" title="http://nomisma.org/id/igch1544"  rel="nofollow">http://nomisma.org/id/igch1544</a>:
							
							<span class="center" id="gmap" about="[nm:igch1544]" > </span>
							<span property="nm:findspot" content="38.183333 22.183333"/>
							
						</p>
						
					</div>
					
					<h3><a name="Geographic_Display" id="Geographic_Display">Geographic Display</a></h3>
					<div class="level3">
						
						<p>
							A KML file is available at <a href="http://nomisma.org/nomisma.org.kml" class="urlextern" title="http://nomisma.org/nomisma.org.kml"  rel="nofollow">http://nomisma.org/nomisma.org.kml</a>
							
						</p>
						
					</div>
					
					<h3><a name="XML_Version" id="XML_Version">XML Version</a></h3>
					<div class="level3">
						
						<p>
							An <acronym title="Extensible Markup Language">XML</acronym> file of all nomisma.org data is available at <a href="http://nomisma.org/nomisma.org.xml" class="urlextern" title="http://nomisma.org/nomisma.org.xml"  rel="nofollow">http://nomisma.org/nomisma.org.xml</a>
							
						</p>
						
					</div>
					
					<h3><a name="Semantic_Web_and_Linked_Data" id="Semantic_Web_and_Linked_Data">Semantic Web and Linked Data</a></h3>
					<div class="level3">
						
						<p>
							Nomisma.org has adopted the principles of the Semantic Web and Linked Data. Its resources are represented using xml, the Extensible Markup Language. In particular, xhtml with embedded rdf will permit the information to be both human readable and automatically processed. As an indication of the latter, the <acronym title="Uniform Resource Identifier">URI</acronym> <a href="id/igch0156" class="urlextern" title="http://nomisma.org/id/igch0156"  rel="nofollow">http://nomisma.org/id/igch0156</a>, leads to a description of the hoard that contains an embedded reference to the ancient site of Eretria, the mint for some of the coins in this hoard. The <acronym title="Uniform Resource Identifier">URI</acronym> for Eretria in turn refers to the Pleiades identifier for that city (<a href="http://pleiades.stoa.org/places/579925" class="urlextern" title="http://pleiades.stoa.org/places/579925"  rel="nofollow">http://pleiades.stoa.org/places/579925</a>). The goal is to make this link to the external resource recognizable to third-party processors. The project intends to make all its data available in formats that support independent querying and reuse of its resources.
						</p>
						
						<p>
							
							The default xml namespace is &#039;<a href="http://nomisma.org/id/" class="urlextern" title="http://nomisma.org/id/"  rel="nofollow">http://nomisma.org/id/</a>&#039;.
						</p>
						
					</div>
					
					<h3><a name="Steering_Commitee" id="Steering_Commitee">Steering Commitee</a></h3>
					<div class="level3">
						<ul>
							<li class="level1"><div class="li"> Sebastian Heath, Institute for the Study of the Ancient World</div>
							</li>
							<li class="level1"><div class="li"> Andrew Meadows, American Numismatic Society</div>
							</li>
							<li class="level1"><div class="li"> Daniel Pett, British Museum</div>
							</li>
							<li class="level1"><div class="li"> David Wigg-Wolf, Roemisch-Germanische Kommission, Frankfurt</div>
							</li>
						</ul>
						
						<p>
							
							Correspondence can be directed to Heath or Meadows.
						</p>
						
						<p>
							
							Nomisma.org also hosts the Numismatic Database Standard at <a href="http://nomisma.org/nuds/numismatic_database_standard" class="urlextern" title="http://nomisma.org/nuds/numismatic_database_standard"  rel="nofollow">http://nomisma.org/nuds/numismatic_database_standard</a> .
						</p>
						
					</div>
					
				</div>
				
				<!-- footer -->
				<xsl:call-template name="footer"/>
				
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
