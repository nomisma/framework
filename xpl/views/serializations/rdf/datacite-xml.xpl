<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<!-- execute SPARQL queries to get first and last dates of modification of IDs-->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/nomisma/ui/sparql/getEditedIdsDate.sparql</url>
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
	
	<!-- get earliest date -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="query" href="#query-document"/>
		<p:input name="config-xml" href="../../../../config.xml"/>
		<p:input name="data" href="#data"/>
		
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				
				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
				<xsl:variable name="query" select="doc('input:query')"/>
				<xsl:variable name="uri" select="/rdf:RDF/*[1]/@rdf:about"/>
				<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%URI%', $uri), '%ORDER%', 'ASC')), '&amp;output=xml')"/>
				
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
		<p:output name="data" id="start-url-generator-config"/>
	</p:processor>
	
	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#start-url-generator-config"/>
		<p:output name="data" id="start-date"/>
	</p:processor>
	
	<!-- get latest date -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="query" href="#query-document"/>
		<p:input name="config-xml" href="../../../../config.xml"/>
		<p:input name="data" href="#data"/>
		
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				
				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
				<xsl:variable name="query" select="doc('input:query')"/>
				<xsl:variable name="uri" select="/rdf:RDF/*[1]/@rdf:about"/>
				<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%URI%', $uri), '%ORDER%', 'DESC')), '&amp;output=xml')"/>
				
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
		<p:output name="data" id="end-url-generator-config"/>
	</p:processor>
	
	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#end-url-generator-config"/>
		<p:output name="data" id="end-date"/>
	</p:processor>
	
	<!-- initiate the XSLT transformation -->
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="start-date" href="#start-date"/>
		<p:input name="end-date" href="#end-date"/>
		<p:input name="data" href="aggregate('content', #data, ../../../../config.xml)"/>		
		<p:input name="config" href="../../../../ui/xslt/serializations/rdf/datacite-xml.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/xml</content-type>
				<indent>true</indent>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
