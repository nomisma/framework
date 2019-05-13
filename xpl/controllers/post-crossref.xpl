<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
    xmlns:oxf="http://www.orbeon.com/oxf/processors">
    
    <p:param type="input" name="data"/>
    <p:param type="output" name="data"/>
    
    <p:processor name="oxf:unsafe-xslt">
        <p:input name="data" href="../../crossref-config.xml"/>
        <p:input name="config">
            <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                
                <xsl:template match="/">
                    <xsl:variable name="api">https://test.crossref.org/servlet/deposit</xsl:variable>
                    <xsl:variable name="username" select="/crossref-config/username"/>				
                    <xsl:variable name="password" select="/crossref-config/password"/>
                    
                    <exec dir="/usr/local/projects/nomisma/script"
                        executable="curl">
                        <arg line="-H 'User-Agent: Nomisma.org/XForms' -F operation=doMDUpload -F login_id={$username} -F login_passwd={$password} -F fname=@/tmp/crossref.xml {$api}"/>
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
    
    <p:processor name="oxf:to-xml-converter">
        <p:input name="data" href="#stdout"/>
        <p:input name="config">
            <config>
                <handle-xinclude>true</handle-xinclude>
            </config>
        </p:input>
        <p:output name="data" id="model"/>
    </p:processor>    
    
    <p:processor name="oxf:xml-converter">
        <p:input name="data" href="#model"/>
        <p:input name="config">
            <config>
                <content-type>application/xml</content-type>
                <encoding>utf-8</encoding>
                <version>1.0</version>
            </config>
        </p:input>
        <p:output name="data" ref="data"/>
    </p:processor>
    
</p:config>