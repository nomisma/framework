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
	
	<!-- gather directory scanner -->
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<config>
						<base-directory>
							<xsl:value-of select="concat(/config/data_path, '/ontology')"/>
						</base-directory>
						<include>*.rdf</include>						
						<case-sensitive>true</case-sensitive>
					</config>	
				</xsl:template>
			</xsl:stylesheet>
		</p:input>		
		<p:output name="data" id="scanner-config"/>
	</p:processor>
	
	<p:processor name="oxf:directory-scanner">
		<p:input name="config" href="#scanner-config"/>
		<p:output name="data" id="directory-scan"/>
	</p:processor>	
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', ../../../config.xml, #data, #directory-scan)"/>		
		<p:input name="config" href="../../../ui/xslt/pages/ontology.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
	

</p:config>
