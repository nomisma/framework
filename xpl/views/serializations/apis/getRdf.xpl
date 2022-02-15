<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date modified: February 2022
	Function: Use RDFLib Python3 library to serialize RDF/XML getRDF API response more consistently instead of XSLT
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
	
	<p:processor name="oxf:xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:param name="format" select="/request/parameters/parameter[name='format']/value"/>
				
				<xsl:template match="/">
					<format>
						<xsl:choose>
							<xsl:when test="$format='ttl'">ttl</xsl:when>
							<xsl:when test="$format='json'">jsonld</xsl:when>
							<xsl:otherwise>xml</xsl:otherwise>
						</xsl:choose>
					</format>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="format"/>
	</p:processor>
	
	<p:choose href="#format">
		<p:when test="format='ttl'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="oxf:/apps/nomisma/config.xml"/>
				<p:input name="request" href="#request"/>				
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:param name="identifiers" select="doc('input:request')/request/parameters/parameter[name='identifiers']/value"/>
						
						
						<xsl:template match="/">
							<xsl:variable name="url" select="concat(/config/url, 'apis/getRdf?identifiers=', encode-for-uri($identifiers))"/>
							
							<exec dir="/usr/local/projects/nomisma/script"
								executable="./serialize-api.py">
								<arg line="{$url} ttl"/>
							</exec>                    	
						</xsl:template>
					</xsl:stylesheet>
				</p:input>		
				<p:output name="data" id="execute-processor-config"/>
			</p:processor>
			
			<!-- Execute command -->
			<p:processor name="oxf:execute-processor">
				<p:input name="config" href="#execute-processor-config"/>
				<p:output name="stdout" id="stdout"/>
				<!--<p:output name="stderr" id="stderr"/>
				<p:output name="result" id="result"/>-->
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#stdout"/>
				<p:input name="config">
					<config>
						<content-type>text/turtle</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="format='jsonld'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="oxf:/apps/nomisma/config.xml"/>
				<p:input name="request" href="#request"/>				
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:param name="identifiers" select="doc('input:request')/request/parameters/parameter[name='identifiers']/value"/>
						
						
						<xsl:template match="/">
							<xsl:variable name="url" select="concat(/config/url, 'apis/getRdf?identifiers=', encode-for-uri($identifiers))"/>
							
							<exec dir="/usr/local/projects/nomisma/script"
								executable="./serialize-api.py">
								<arg line="{$url} jsonld"/>
							</exec>                    	
						</xsl:template>
					</xsl:stylesheet>
				</p:input>		
				<p:output name="data" id="execute-processor-config"/>
			</p:processor>
			
			<!-- Execute command -->
			<p:processor name="oxf:execute-processor">
				<p:input name="config" href="#execute-processor-config"/>
				<p:output name="stdout" id="stdout"/>
				<!--<p:output name="stderr" id="stderr"/>
				<p:output name="result" id="result"/>-->
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#stdout"/>
				<p:input name="config">
					<config>
						<content-type>application/ld+json</content-type>						
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>			
			<p:processor name="oxf:xml-converter">
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<config>
						<content-type>application/rdf+xml</content-type>
						<encoding>utf-8</encoding>
						<version>1.0</version>
						<indent>true</indent>
						<indent-amount>4</indent-amount>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
