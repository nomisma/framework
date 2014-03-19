<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	
	<xsl:variable name="id-path" select="/config/id_path"/>
	<xsl:param name="identifiers" select="doc('input:request')/request/parameters/parameter[name='identifiers']/value"/>
	
	<xsl:template match="/">
		<body xmlns="http://www.w3.org/1999/xhtml">
			<xsl:for-each select="tokenize($identifiers, '\|')">				
				<xsl:if test="doc-available(concat('file://', $id-path, '/', ., '.txt'))">
					<xsl:copy-of select="document(concat('file://', $id-path, '/', ., '.txt'))/*"/>
				</xsl:if>				
			</xsl:for-each>
		</body>
	</xsl:template>
	
</xsl:stylesheet>
