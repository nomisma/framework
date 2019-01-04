<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last modified: January 2019
	Function: execute a SPARQL query to extract a list of spreadsheets associated with a Nomisma editor
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<!-- get query from a text file on disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/nomisma/ui/sparql/getSpreadsheets.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="query"/>
	</p:processor>

	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#query"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="query-document"/>
	</p:processor>

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="query" href="#query-document"/>
		<p:input name="request" href="#request"/>
		<p:input name="config-xml" href="../../../config.xml"/>
		<p:input name="data" href="#data"/>

		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
				<xsl:variable name="query" select="doc('input:query')"/>
				<xsl:variable name="uri" select="/rdf:RDF/*[1]/@rdf:about"/>
				<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%URI%', $uri)), '&amp;output=xml')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
