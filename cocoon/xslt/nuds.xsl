<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="templates.xsl"/>

	<xsl:variable name="display_path">../</xsl:variable>

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
						<a name="Introduction" id="Introduction">Numismatic Description Standard (NUDS)</a>
					</h3>
					<p> NUDS is a set of suggested field names for recording numismatic information in a column-oriented database. It is designed to capture information as it currently exists in
						databases deployed by museums and collectors in "real world" situations. It is flexible in that it can represent objects for which only very generic information is known or
						objects that have been described in detail. It does not mandate a set of required fields. </p>
					<p> A main goal in the design of NUDS is that it capture the distinctive categories of numismatic data that are fundamental to the discipline. Primary among these is the
						distinction between obverse and reverse. It is extremely important that numismatists be able to search for the occurence of words or visual motifs on the distinct sides of
						coins. NUDS also recognizes that the edge of a coin often needs to be separately described. Obverse, reverse, and edge are constituent "parts" of a coin. NUDS can also
						represent particular concepts that are likewise important to numismatists. The concept "denomination," whether explicitly assigned at the the time of production or identified
						by later scholars, applies to almost all officially issued coins. It is not a field that appears in many museum collection systems. Likewise, "axis" - or the orientation of the
						obverse to the reverse - is important for numismatic study but not often accounted for in non-numismatic databases. </p>
					<p> The list that follows presents the current suggested categories of information that NUDS can record. It is not strictly a list of field names nor is it intended to serve as a
						fully implemented numismatic database. This is particularly the case for generic names that are likely to be repeated for a single object. For example, the list includes the
						entry "Geography(1,2,3)". "Geography" provides a placeholder for uncategorized geographic information - e.g., "Attica". The "(1,2,3..)" indicates that in an actual database
						management system (DBMS), it may be necessary to append numerals to each instance of a "Geography" column so as to avoid duplicate column names. Alternately, a one-to-many
						relationship can be established within a relational database management system. Either representation is suitable in different contexts and both can easily be mapped to NUDS. </p>
					<p> Finally, it is important to address two limits of NUDS as currently defined. First, NUDS is concerned with the structure of numismatic information but has not yet expanded to
						define the contents of fields. I.e., NUDS makes no recomendation as to how to represent the metal silver in its records. "Silver", "argent", "silber","AR", "Ag" are all
						acceptable. Second, a column-oriented approach to the representation of numismatic information places limitations on the utility of data. For example, NUDS currently defines a
						very generic "published" field. This is a "free-text" container and it is likely that its contents will vary considerably across projects. The issue of multiple values for
						single concepts, such as material or geography, has already been addressed. Both of these issues are be flexibly handled by an XML schema for numismatics, implemented and and
						maintained by Ethan Gruber of the American Numismatic Society. See <a href="http://wiki.numismatics.org/nuds:nuds">documentation</a> for the NUDS/XML <a
							href="https://github.com/ewg118/NUDS">XSD Schema</a>, hosted on GitHub</p>
					<!--<p> To facilitate conversation, nomisma.org also maintains a [[public_databases|short list]] of public databases with substantial numismatic content. </p>-->
					<p> Initial work on the development of NUDS was undertaken at a series of workshops in 2006-2007, funded by the AHRC in the UK. </p>
					<h3>Field Names</h3>
					<h4>Identifying Information</h4>
					<p> At a minimum each record should have a unique identifier specified by the UniqueID field. Records can have many associated identifiers and NUDS provides a set of fields that
						allow recording of common scenarios. These are not required and in many instances the unique id will be sufficient. </p>
					<p> A particularly common scenario is a database that describes coins held in a pre-existing collection, such as that of a museum. In this instance, the Collection and CollectionID
						fields should be used. </p>
					<ul>
						<li>UniqueID - The unique identifier of the record within the current database.</li>
						<li>Collection - Identifier of the collection where the object is currently held</li>
						<li>CollectionID - Identifier of the object within its collection</li>
						<li>GovernmentID - An official ID assigned by a governmental entity such as an archaeological service</li>
						<li>Project - Identifier of the project creating this record</li>
						<li>ProjectID - Identifier of the object</li>
						<li>CatalogID - Accomodates the situation where UniqueID is not the identifier that will be used in a publication generated from the database.</li>
						<li>OtherID(1,2,3) - Generic placeholder for other identifiers.</li>
						<li>InformationSource</li>
					</ul>

					<h4>Descriptive</h4>
					<p> This section lists fields that describe aspects of the entire object. </p>
					<ul>
						<li>Title http://purl.org/dc/elements/1.1/title</li>
						<li>Category</li>
						<li>ObjectType <ul>
								<li> http://nomisma.org/id/coin</li>
								<li> http://nomisma.org/id/medal</li>
								<li> http://nomisma.org/id/seal</li>
								<li> http://nomisma.org/id/sealing</li>
								<li> http://nomisma.org/id/token</li>
							</ul>
						</li>

						<li>Description - Free text holder for undifferentiated description of object</li>
						<li>Denomination http://nomisma.org/id/denomination</li>
						<li>Countermark - used when countermark not assigned to obverse or reverse. http://nomisma.org/id/countermark</li>
					</ul>

					<h4>Physical</h4>
					<ul>
						<li>Material(1,2,3...) http://nomisma.org/id/material</li>
						<li>Manufacture http://nomisma.org/id/manufacture</li>
						<li>Weight http://nomisma.org/id/weight</li>
						<li>Diameter http://nomisma.org/id/diameter</li>
						<li>Height http://nomisma.org/id/height</li>
						<li>Width http://nomisma.org/id/width</li>
						<li>Thickness http://nomisma.org/id/thickness</li>
						<li>OtherDimension(1,2,3...)</li>
						<li>Shape</li>
						<li>Axis http://nomisma.org/id/axis</li>
						<li>AxisClock</li>
						<li>AxisNumber</li>
					</ul>

					<h4>Geography (currently including Hoard and Findspot Information)</h4>
					<ul>
						<li>Geographic(1,2,3...)</li>
						<li>Region http://nomisma.org/id/region</li>
						<li>Mint http://nomisma.org/id/mint</li>
						<li>fsGeographic(1,2,3...)</li>
						<li>Findspot</li>
						<li>fsCoordinates</li>
						<li>Hoard http://nomisma.org/id/hoard</li>
					</ul>

					<h4>Authority and Personal</h4>
					<ul>
						<li>State</li>
						<li>Authority(1,2,3...) http://nomisma.org/id/authority</li>
						<li>Issuer(1,2,3...) http://nomisma.org/id/issuer</li>
						<li>Artist http://nomisma.org/id/artist</li>
						<li>Engraver http://nomisma.org/id/engraver</li>
					</ul>

					<h4>Chronology</h4>
					<p> Use '-' to indicate BC/BCE dates. For example "-323" for the date 323 BCE. </p>
					<ul>
						<li>fromDate</li>
						<li>toDate</li>
						<li>Date</li>
						<li>DateOnObject</li>
						<li>DateonObjectEra</li>
					</ul>

					<h4>Obverse</h4>
					<ul>
						<li>ObverseDescription - Free text holder for undifferentiated description of obverse</li>
						<li>ObverseLegend</li>
						<li>ObverseType</li>
						<li>ObverseSymbol</li>
						<li>ObverseDieID</li>
						<li>ObverseDieState</li>
						<li>ObverseCountermark</li>
						<li>ObverseArtist</li>
						<li>ObverseEngraver</li>
					</ul>

					<h4>Reverse</h4>
					<ul>
						<li>ReverseDescription - Free text holder for undifferentiated description of reverse</li>
						<li>ReverseLegend</li>
						<li>RebverseType</li>
						<li>ReverseSymbol</li>
						<li>ReverseDieID</li>
						<li>ReverseDieState</li>
						<li>ReverseCountermark</li>
						<li>ReverseArtist</li>
						<li>ReverseEngraver</li>
					</ul>

					<h4>Edge</h4>
					<ul>
						<li>EdgeDescription</li>
						<li>EdgeType</li>
						<li>EdgeLegend</li>
					</ul>

					<h4>Undertype</h4>
					<p> The approach to undertype is currently very generic and allows for an unstructured description of the original coin. It is possible, however, to prepend "ut" to any NUDS field
						and so indicate that it applies to the undertype. </p>
					<ul>
						<li>Undertype</li>
						<h4>Publication and Reference</h4>
						<li>AbbreviatedNumismaticReference(1,2,3) - Abbreviated reference to recognized numismatic typology (e.g. "RIC.20")</li>
						<li>Reference(1,2,3) - Free text reference to numismatic typology.</li>
						<li>Published(1,2,3) - Free text reference to publication of the specific object described by the current record.</li>
					</ul>

					<h4>Fields useful in Sigillography</h4>
					<ul>
						<li> Indiction - Numbered year within a 15 year sequence. (or is this an identification of which 15 year period). - http://nomisma.org/id/indiction</li>
					</ul>

					<h4>Condition</h4>
					<ul>
						<li>Condition</li>
						<li>Wear</li>
						<li>Completeness</li>
						<li>Grade</li>
					</ul>

					<h4>Images</h4>
					<ul>
						<li>ImageUrl</li>
						<li>ObverseImageUrl</li>
						<li>ReverseImageUrl</li>
					</ul>

					<h4>Provenience</h4>
					<ul>
						<li>PreviousHistory</li>
						<li>AcquiredDate</li>
						<li>AcquiredFrom</li>
						<li>SaleCatalog</li>
						<li>SaleItem</li>
						<li>SalePrice</li>
					</ul>

					<h4>Collections Management</h4>
					<p> NUDS is not intended to include all the fields that would be found in a fully-implemented collections management system. Providing the ability to exchange such information may
						be useful in some circumstances. It is also likely, however, that most institutions will not share value and current location information. </p>
					<ul>
						<li>Value</li>
						<li>ValueBy</li>
						<li>ValueDate</li>
						<li>CurrentLocation</li>
						<li>OnDisplay</li>
						<li>DisplayInstitution</li>
						<li>DisplayLocation</li>
						<li>DisplayLabel</li>
						<li>Repository - Current location of the object</li>
						<li>Owner</li>
						<li>Acknowledgment</li>
						<h4>Copyright, Rights and Licence</h4>
						<li>CopyrightHolder - who holds the copyright to the information in this record</li>
						<li>CopyrightDate</li>
						<li>rightsStatement</li>
						<h4>Record Metadata</h4>
						<li>TypeOfRecord - Allows distinction between description of an actual object or an idealized description of a numismatic type.</li>
						<li>RecordHistory</li>
						<li>DateRecordCreated</li>
						<li>DateRecordUpdated</li>
						<li>CreatedBy</li>
						<li>UpdatedBy</li>
						<li>Language</li>
					</ul>
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
							<a href="http://finds.org.uk/" title="http://finds.org.uk/" rel="nofollow">
								<img src="http://finds.org.uk/images/logos/pas.gif" alt="http://finds.org.uk/"/>
							</a>
						</div>
						<div class="media">
							<a href="http://www.britishmuseum.org/" title="http://www.britishmuseum.org/" rel="nofollow">
								<img src="http://finds.org.uk/images/logos/bm_logo.png" alt="http://www.britishmuseum.org/"/>
							</a>
						</div>
						<div class="media">
							<a href="http://www.dainst.org/" title="http://www.dainst.org/" rel="nofollow">
								<img src="images/GreifBlau.jpg" alt="http://www.dainst.org/"/>
							</a>
						</div>
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
					<xsl:text> | </xsl:text>
					<a href="nomisma.org.rdf">RDF/XML</a>
					<xsl:text> | </xsl:text>
					<a href="nomisma.org.ttl">Turtle</a>
					<xsl:text> | </xsl:text>
					<a href="nomisma.org.nt">N-Triples</a>
					<xsl:text> | </xsl:text>
					<a href="nomisma.org.rj">RDF/JSON</a>
					<xsl:text> | Stay up to date with the latest changes: </xsl:text>
					<a href="feed/?q=*:*">Atom</a>
					<xsl:text> (</xsl:text>
					<a href="http://numishare.blogspot.com/2013/07/updates-to-nomisma-atom-feed.html">documentation</a>
					<xsl:text>)</xsl:text>
				</div>
				<!-- footer -->
				<xsl:call-template name="footer"/>

			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
