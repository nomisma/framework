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
                
                <xsl:template match="/">
                    <xsl:variable name="request-url" select="/request/request-url"/>
                    <xsl:variable name="pieces" select="tokenize($request-url, '/')"/>				
                    <xsl:variable name="scheme" select="$pieces[count($pieces) - 1]"/>
                    
                    <xsl:variable name="id" select="substring-before($pieces[last()], '.jsonld')"/>                       
                    				
                    
                    <exec dir="/usr/local/projects/nomisma/script"
                        executable="./rdf-to-json.py">
                        <arg line="{$id} {$scheme}"/>
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
    
    <!-- Output stdout -->
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
    
</p:config>