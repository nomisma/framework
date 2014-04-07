<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="request" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<xsl:variable name="page" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
					<redirect-url>
						<path-info>
							<xsl:value-of select="concat('/nomisma/', $page, '/')"/>
						</path-info>
					</redirect-url>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor xmlns:p="http://www.orbeon.com/oxf/pipeline" name="oxf:redirect">
		<p:input name="data" href="#config"/>
	</p:processor>
</p:config>
