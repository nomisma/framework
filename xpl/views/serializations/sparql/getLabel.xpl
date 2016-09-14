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

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#data"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/sparql/getLabel.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<!-- control serialization -->
	<p:processor name="oxf:xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:param name="output" select="/request/parameters/parameter[name='format']/value"/>				
				
				<xsl:template match="/">
					<mode>
						<xsl:choose>							
							<xsl:when test="$output='json' or $output='jsonp'">json</xsl:when>
							<xsl:otherwise>xml</xsl:otherwise>
						</xsl:choose>
					</mode>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="serialization-config"/>
	</p:processor>
	
	<p:choose href="#serialization-config">
		<p:when test="mode='json'">
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#model"/>
				<p:input name="config">
					<config>
						<content-type>application/json</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="mode='xml'">
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
