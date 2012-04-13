<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:h="http://www.w3.org/1999/xhtml"
xmlns:saxon="http://icl.com/saxon"
extension-element-prefixes="saxon"
>
<xsl:output method="xml" encoding="utf-8"/>

<xsl:template match="/">
<xsl:apply-templates select="/h:html/h:body/h:div[@about]"/>
</xsl:template>

<xsl:template match="*[@about]">
<saxon:output file="{@about}.xml">
<xsl:copy-of select="."/>
</saxon:output>
</xsl:template>
</xsl:stylesheet>