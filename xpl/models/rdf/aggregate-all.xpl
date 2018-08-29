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
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:variable name="directory" select="concat('file:', /config/data_path)"/>

				<xsl:template match="/">
					<config>
						<base-directory>
							<xsl:value-of select="$directory"/>
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
		<p:input name="data" href="#directory-scan"/>
		<p:input name="config">
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsl xs"
				xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
				xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#" xmlns:rdac="http://www.rdaregistry.info/Elements/c/"
				xmlns:dcterms="http://purl.org/dc/terms/" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:nm="http://nomisma.org/id/"
				xmlns:nmo="http://nomisma.org/ontology#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:prov="http://www.w3.org/ns/prov#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" version="2.0">
				
				<xsl:template match="/">
					<rdf:RDF>
						<xsl:apply-templates/>
					</rdf:RDF>
				</xsl:template>
				
				<xsl:template match="directory">
					<xsl:param name="path"/>
					
					<xsl:apply-templates>
						<xsl:with-param name="path" select="if (string-length($path) = 0) then @path else concat($path, '/', @path)"/>
					</xsl:apply-templates>
					
				</xsl:template>
				
				<xsl:template match="file">
					<xsl:param name="path"/>
					
					<xsl:variable name="file" select="concat($path, '/', encode-for-uri(@name))"/>
					<xsl:copy-of select="document(concat('file://', $file))/rdf:RDF/*"/>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
