<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: July 2022
	Function: Respond with 400 Bad Request for an API error, conforming to JSend format -->
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:saxon="http://saxon.sf.net/">

	<p:param type="input" name="data"/>

	<!-- generate HTML fragment to be returned -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:saxon="http://saxon.sf.net/">
				<xsl:output name="json" encoding="UTF-8" method="text"/>

				<xsl:include href="../../ui/xslt/functions.xsl"/>
				<xsl:include href="../../ui/xslt/serializations/json/json-metamodel.xsl"/>

				<!-- construct an object that conforms to JSend JSON response format: https://github.com/omniti-labs/jsend -->
				<xsl:template match="/">
					<xsl:variable name="model" as="element()*">
						<_object>
							<status>fail</status>
							<data>
								<_object>
									<xsl:apply-templates select="//error"/>
								</_object>
							</data>

						</_object>
					</xsl:variable>

					<xsl:variable name="json-text">
						<xsl:apply-templates select="$model"/>
					</xsl:variable>

					<xml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" content-type="application/json">
						<xsl:value-of select="saxon:serialize($json-text, 'json')"/>
					</xml>

				</xsl:template>

				<xsl:template match="error">
					<xsl:element name="{@key}">
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="error-body"/>
	</p:processor>

	<!-- generate config for http-serializer -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<config>
						<status-code>400</status-code>
						<content-type>application/json</content-type>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="header"/>
	</p:processor>

	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#error-body"/>
		<p:input name="config" href="#header"/>
	</p:processor>
</p:pipeline>
