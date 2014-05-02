<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
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

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- url params -->
				<xsl:variable name="output" select="substring-after(doc('input:request')/request/request-url, 'nomisma.org.')"/>
				
				
				<!-- config variables -->
				<xsl:variable name="dump_path" select="/config/dump_path"/>				
				<xsl:variable name="service" select="concat('file://', $dump_path, '/nomisma.org.', $output)"/>
				
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>
							<xsl:choose>
								<xsl:when test="$output='ttl'">text/plain</xsl:when>
								<xsl:when test="$output='nt'">text/plain</xsl:when>
								<xsl:when test="$output='rdf'">application/rdf+xml</xsl:when>								
							</xsl:choose>
						</content-type>
						<xsl:if test="$output='ttl' or $output='nt'">
							<mode>text</mode>
						</xsl:if>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="url-generator-config"/>
	</p:processor>
	
	<!-- generate the serializer config -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:variable name="output" select="substring-after(/request/request-url, 'nomisma.org.')"/>
				
				<xsl:template match="/">
					<mode>
						<xsl:choose>
							<xsl:when test="$output='ttl'">ttl</xsl:when>
							<xsl:when test="$output='nt'">nt</xsl:when>
							<xsl:when test="$output='rdf'">rdf</xsl:when>
						</xsl:choose>
					</mode>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="parser-config"/>
	</p:processor>
	
	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<!-- serialize it -->
	<p:choose href="#parser-config">
		<p:when test="mode='ttl'">
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
		<p:when test="mode='nt'">
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#model"/>
				<p:input name="config">
					<config>
						<content-type>text/plain</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="mode='rdf'">
			<p:processor name="oxf:xml-converter">
				<p:input name="data" href="#model"/>
				<p:input name="config">
					<config>
						<content-type>application/xml</content-type>
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
