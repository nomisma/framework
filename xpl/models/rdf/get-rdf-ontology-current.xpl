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
						<base-directory>
							<xsl:value-of select="concat('file://', /config/ontology_path)"/>
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
		<p:input name="data" href="#directory-scan"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="doc">
						<xsl:for-each select="//file">
							<xsl:sort select="@name" order="ascending"/>
							<xsl:if test="position()=last()">
								<xsl:value-of select="@name"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>					
					
					<config>
						<url>
							<xsl:value-of select="concat('file://', /directory/@path, '/', $doc)"/>
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
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/rdf+xml</content-type>
				<indent>true</indent>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>

