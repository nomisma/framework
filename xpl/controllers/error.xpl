<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date Modified: March 1, 2021
	Function: Return an HTTP 400 error code for a bad SPARQL query -->
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:saxon="http://saxon.sf.net/">

	<p:param type="input" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<!--<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="status-code" select="/*/@status-code"/>

					<xsl:choose>
						<xsl:when test="$status-code castable as xs:integer">
							<code>
								<xsl:value-of select="$status-code"/>
							</code>
						</xsl:when>
						<xsl:otherwise>
							<code>503</code>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="code"/>
	</p:processor>-->

	<!-- generate HTML fragment to be returned -->

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="status-code" select="/*/@status-code"/>
					
					<html xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<head>
							<title>400: Bad Request</title>
						</head>
						<body>
							<h1>400: Bad Request</h1>
							<p>There is likely a validation error in the SPARQL query.</p>
						</body>
					</html>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="html"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="status-code" select="/*/@status-code"/>
					<config>
						<status-code>400</status-code>
						<content-type>text/html</content-type>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="header"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#html"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output name="html" encoding="UTF-8" method="html" indent="yes" omit-xml-declaration="yes" doctype-system="HTML"/>

				<xsl:template match="/">
					<xml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema"
						content-type="text/html">
						<xsl:value-of select="saxon:serialize(/html, 'html')"/>
					</xml>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="converted"/>
	</p:processor>

	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#converted"/>
		<p:input name="config" href="#header"/>
	</p:processor>
</p:pipeline>
