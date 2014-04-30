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
	
	<!-- read ids in the XHTML+RDFa, aggregate them -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="aggregate('content', ../../../config.xml, #data)"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:variable name="id-path" select="/content/config/id_path"/>
				
				<xsl:template match="/">
					<body xmlns="http://www.w3.org/1999/xhtml">
						<xsl:for-each select="distinct-values(//@resource[not(contains(., 'http://'))])">				
							<xsl:if test="doc-available(concat('file://', $id-path, '/', ., '.txt'))">
								<xsl:copy-of select="document(concat('file://', $id-path, '/', ., '.txt'))/*"/>
							</xsl:if>				
						</xsl:for-each>
					</body>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="dump"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#dump"/>
		<p:input name="config" href="getRdf.xpl"/>		
		<p:output name="data" id="rdf"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #data, #rdf)"/>
		<p:input name="config" href="../../../ui/xslt/apis/getNuds.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/xml</content-type>
				<encoding>utf-8</encoding>
				<indent>true</indent>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
