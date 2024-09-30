<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date Modified: September 2024
	Function: Query the types and other symbols associated with a symbol URI.
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:res="http://www.w3.org/2005/sparql-results#">

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
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:nomisma="http://nomisma.org/">
				
				<xsl:template match="/">
					<level>
						<xsl:choose>
							<xsl:when test="number(/request/parameters/parameter[name='level']/value)">
								<xsl:choose>
									<xsl:when test="/request/parameters/parameter[name='level']/value &gt; 2">1</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="/request/parameters/parameter[name='level']/value"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</level>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="level"/>
	</p:processor>
	
	<!-- load SPARQL query from disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/nomisma/ui/sparql/query-symbol-relations.sparql</url>
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

	<!-- get symbol URI from request parameter -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">				
				<xsl:template match="/">
					<uri>
						<xsl:value-of select="/request/parameters/parameter[name='uri']/value"/>
					</uri>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="uri"/>
	</p:processor>
	
	<!-- enable the output of immediate or secondary relationship nodes, but not more than that -->
	<p:choose href="#level">
		<p:when test="/level = 1">
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href=" ../../../config.xml"/>
				<p:input name="request" href="#request"/>
				<p:input name="query" href="#query-document"/>		
				<p:input name="uri" href="#uri"/>
				<p:input name="config" href="query-symbol-relations.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href=" ../../../config.xml"/>
				<p:input name="request" href="#request"/>
				<p:input name="query" href="#query-document"/>		
				<p:input name="uri" href="#uri"/>
				<p:input name="config" href="query-symbol-relations.xpl"/>
				<p:output name="data" id="initial-response"/>
			</p:processor>
			
			<p:for-each href="#initial-response" select="//res:binding[@name = 'altSymbol']/res:uri" root="response" id="sparql-response">
				<p:processor name="oxf:pipeline">						
					<p:input name="data" href=" ../../../config.xml"/>
					<p:input name="request" href="#request"/>
					<p:input name="query" href="#query-document"/>		
					<p:input name="uri" href="current()"/>
					<p:input name="config" href="query-symbol-relations.xpl"/>
					<p:output name="data" ref="sparql-response"/>
				</p:processor>
			</p:for-each>
			
			<p:processor name="oxf:identity">
				<p:input name="data" href="aggregate('content', #initial-response, #sparql-response)"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
