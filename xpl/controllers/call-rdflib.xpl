<?xml version="1.0" encoding="UTF-8"?>
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
    
    <p:processor name="oxf:unsafe-xslt">
        <p:input name="data" href="#request"/>
        <p:input name="config">
            <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:variable name="content-type" select="//header[name[.='accept']]/value"/>
                
                
                <xsl:template match="/">
                    <xsl:variable name="pieces" select="tokenize(/request/request-url, '/')"/>
                    
                    <!-- read the accept header first, if available -->
                    <xsl:variable name="format">
                        <xsl:choose>
                            <xsl:when test="$content-type='application/ld+json'">jsonld</xsl:when>
                            <xsl:when test="$content-type='text/turtle'">ttl</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="tokenize($pieces[last()], '\.')[last()]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    
                    <format>
                        <xsl:value-of select="$format"/>
                    </format>	
                </xsl:template>
            </xsl:stylesheet>
        </p:input>		
        <p:output name="data" id="format"/>
    </p:processor>
    
    <p:processor name="oxf:unsafe-xslt">
        <p:input name="data" href="#request"/>
        <p:input name="format" href="#format"/>
        <p:input name="config">
            <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                
                <xsl:template match="/">
                    <xsl:variable name="pieces" select="tokenize(/request/request-url, '/')"/>				
                    <xsl:variable name="scheme" select="$pieces[count($pieces) - 1]"/>
                    <xsl:variable name="format" select="doc('input:format')"/>                    
                    <xsl:variable name="id" select="if (contains($pieces[last()], concat('.', $format))) then substring-before($pieces[last()], concat('.', $format)) else $pieces[last()]"/>
                    
                   <exec dir="/usr/local/projects/nomisma/script"
                        executable="./serialize-rdf.py">
                        <arg line="{$id} {$scheme} {$format}"/>
                    </exec>                    	
                </xsl:template>
            </xsl:stylesheet>
        </p:input>		
        <p:output name="data" id="execute-processor-config"/>
    </p:processor>
    
    <!-- Execute command -->
    <p:processor name="oxf:execute-processor">
        <p:input name="config" href="#execute-processor-config"/>
        <p:output name="stdout" id="stdout"/>
        <p:output name="stderr" id="stderr"/>
        <p:output name="result" id="result"/>
    </p:processor>
    
    <!-- serialize stdout -->
    <p:choose href="#format">
        <p:when test="format='ttl'">
            <p:processor name="oxf:text-converter">
                <p:input name="data" href="#stdout"/>
                <p:input name="config">
                    <config>
                        <content-type>text/turtle</content-type>
                        <encoding>utf-8</encoding>
                    </config>
                </p:input>
                <p:output name="data" ref="data"/>
            </p:processor>
        </p:when>
        <p:when test="format='jsonld'">
            <p:processor name="oxf:text-converter">
                <p:input name="data" href="#stdout"/>
                <p:input name="config">
                    <config>
                        <content-type>application/ld+json</content-type>
                        <encoding>utf-8</encoding>
                    </config>
                </p:input>
                <p:output name="data" ref="data"/>
            </p:processor>
        </p:when>
    </p:choose>
</p:config>