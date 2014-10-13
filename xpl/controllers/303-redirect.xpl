<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<!-- generate HTML fragment to be returned -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<html xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
						xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<head>
							<title>303 See Other</title>
						</head>
						<body>
							<h1>See Other</h1>
							<p>The answer to your request is located <a href="{descendant::dcterms:isReplacedBy/@rdf:resource}">here</a>.</p>
						</body>
					</html>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="converted"/>
	</p:processor>

	<!-- generate config for http-serializer -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<config>
						<status-code>303</status-code>
						<content-type>text/html</content-type>
						<header>
							<name>Location</name>
							<value>
								<xsl:value-of select="descendant::dcterms:isReplacedBy/@rdf:resource"/>
							</value>
						</header>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:html-serializer">
		<p:input name="data" href="#converted"/>
		<p:input name="config" href="#config"/>
	</p:processor>
</p:pipeline>
