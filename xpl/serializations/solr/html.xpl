<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
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
	
	<!-- read request header for content-type -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				
				<xsl:variable name="content-type" select="//header[name[.='content-type']]/value"/>
				
				<xsl:template match="/">
					<content-type>
						<xsl:choose>
							<xsl:when test="$content-type='application/atom+xml'">atom</xsl:when>
							<xsl:when test="$content-type='text/html' or not(string($content-type))">html</xsl:when>
							<xsl:otherwise>error</xsl:otherwise>
						</xsl:choose>
					</content-type>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="conneg-config"/>
	</p:processor>
	
	<!-- handle Atom response for content negotiation -->
	<p:choose href="#conneg-config">
		<p:when test="content-type='atom'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="atom.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='html'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #data, ../../../config.xml)"/>
				<p:input name="config" href="../../../ui/xslt/serializations/solr/html.xsl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../../http/406-not-acceptable.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>