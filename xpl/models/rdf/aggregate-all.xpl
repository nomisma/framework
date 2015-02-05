<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="config-xml"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config-xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<config>
						<base-directory>
							<xsl:value-of select="concat('file://', config/id_path)"/>
						</base-directory>
						<include>*.rdf</include>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="scanner-config"/>
	</p:processor>
	
	<p:processor name="oxf:directory-scanner">
		<p:input name="config" href="#scanner-config"/>
		<p:output name="data" id="directory-scan"/>		
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#directory-scan"/>
		<p:input name="config-xml" href="#config-xml"/>
		<p:input name="config">
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsl xs" version="2.0">				
				<xsl:template match="/">					
					<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
						xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
						xmlns:ecrm="http://erlangen-crm.org/current/" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#"
						xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:org="http://www.w3.org/ns/org#">
						<xsl:for-each select="//file">
							<xsl:copy-of select="document(concat('file://', doc('input:config-xml')/config/id_path, '/', @name))/rdf:RDF/*"/>
						</xsl:for-each>
					</rdf:RDF>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>