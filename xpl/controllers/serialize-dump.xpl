<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Author: Ethan Gruber
	Date: August 2018
	Function: Associate the correct content type in the HTTP header for static Nomisma exports stored in the filesystem
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
	
	<!-- get mode -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:variable name="output" select="substring-after(/request/request-url, 'nomisma.org.')"/>
				
				<xsl:template match="/">
					<mode>
						<xsl:choose>
							<xsl:when test="$output='ttl'">ttl</xsl:when>
							<xsl:when test="$output='jsonld'">jsonld</xsl:when>
							<xsl:when test="$output='rdf'">rdf</xsl:when>
						</xsl:choose>
					</mode>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="parser-config"/>
	</p:processor>
	
	<!-- serialize it -->
	<p:choose href="#parser-config">
		<p:when test="mode='ttl'">
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/nomisma/dump/nomisma.org.ttl</url>						
						<mode>text</mode>
						<content-type>text/turtle</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" id="model"/>
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#model"/>
				<p:input name="config">
					<config>
						<content-type>text/turtle</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="mode='jsonld'">
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/nomisma/dump/nomisma.org.jsonld</url>						
						<mode>text</mode>
						<content-type>application/ld+json</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" id="model"/>
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#model"/>
				<p:input name="config">
					<config>
						<content-type>application/ld+json</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="mode='rdf'">
			<!--<p:processor name="oxf:pipeline">
				<p:input name="data" href="../../config.xml"/>
				<p:input name="config" href="../models/rdf/aggregate-all.xpl"/>
				<p:output name="data" id="rdfxml"/>
			</p:processor>-->
			
			<p:processor name="oxf:xml-converter">
				<p:input name="data" href="../../dump/nomisma.org.rdf"/>
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
		</p:when>
	</p:choose>
</p:config>
