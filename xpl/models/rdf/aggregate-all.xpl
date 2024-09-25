<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: August 2018
	Function: Use the Orbeon directory-scanner processor to get a listing of all RDF files in the data_path. Aggregate into one RDF/XML file
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<!-- create the directory scanner config -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="data_path" select="/config/data_path"/>

				<xsl:template match="/">
					<config>
						<base-directory>
							<xsl:value-of select="$data_path"/>
						</base-directory>
						<include>**/*.rdf</include>
						<exclude>ontology/*.rdf</exclude>
						<case-sensitive>true</case-sensitive>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="directory-config"/>
	</p:processor>

	<p:processor name="oxf:directory-scanner">
		<p:input name="config" href="#directory-config"/>
		<p:output name="data" id="directory-scan"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="config-xml" href="../../../config.xml"/>
		<p:input name="data" href="#directory-scan"/>
		<p:input name="config">
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsl xs"
				xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
				xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
				xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#" xmlns:rdac="http://www.rdaregistry.info/Elements/c/"
				xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:org="http://www.w3.org/ns/org#"
				xmlns:bio="http://purl.org/vocab/bio/0.1/" xmlns:prov="http://www.w3.org/ns/prov#" xmlns:wordnet="http://ontologi.es/WordNet/class/"
				xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/" version="2.0">

				<xsl:variable name="data_path" select="doc('input:config-xml')/config/data_path"/>

				<xsl:template match="/">
					<rdf:RDF>
						<xsl:apply-templates/>
					</rdf:RDF>
				</xsl:template>

				<xsl:template match="directory">
					<xsl:apply-templates select="descendant::file"/>
				</xsl:template>

				<xsl:template match="file">

					<xsl:variable name="file" select="concat($data_path, '/', @path)"/>

					<xsl:copy-of select="document($file)/rdf:RDF/*"/>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
