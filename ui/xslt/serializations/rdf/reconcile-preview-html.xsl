<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" exclude-result-prefixes="xs" version="2.0">

	<xsl:template match="/rdf:RDF">
		<xsl:apply-templates select="*[1]" mode="concept"/>
	</xsl:template>

	<xsl:template match="*" mode="concept">
		<html>
			<head>
				<meta charset="utf-8"/>
				<title>
					<xsl:value-of select="skos:prefLabel[@xml:lang = 'en']"/>
				</title>
			</head>
			<body style="margin: 0px; font-family: Arial; sans-serif">
				<div style="height: 90px; width: 320px; overflow: hidden; font-size: 0.7em">
					<div>
						<a href="{@rdf:about}" target="_blank" style="text-decoration: none;">
							<xsl:value-of select="skos:prefLabel[@xml:lang = 'en']"/>
						</a>
						<xsl:text> </xsl:text>
						<span style="color: #505050;">(<xsl:value-of select="tokenize(@rdf:about, '/')[last()]"/>)</span>
						<p>
							<xsl:text>[</xsl:text>
							<xsl:value-of select="local-name()"/>
							<xsl:text>] </xsl:text>
							<xsl:value-of select="skos:definition[@xml:lang = 'en']"/>
						</p>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
