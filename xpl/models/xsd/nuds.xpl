<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">
	
	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="/config/nuds_xsd_path"/>
						</url>						
						<mode>xml</mode>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>			
				</xsl:template>
			</xsl:stylesheet>
		</p:input>		
		<p:output name="data" id="url-generator-config"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>

