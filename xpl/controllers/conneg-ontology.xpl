<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
	
	<!-- read request header for content-type -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				
				<xsl:variable name="content-type" select="//header[name[.='accept']]/value"/>
				
				<xsl:template match="/">
					<content-type>
						<xsl:choose>
							<xsl:when test="$content-type='application/rdf+xml' or $content-type='application/xml' or $content-type='text/xml'">xml</xsl:when>
							<xsl:when test="$content-type='text/turtle'">turtle</xsl:when>
							<xsl:when test="contains($content-type, 'text/html') or $content-type='*/*' or not(string($content-type))">html</xsl:when>
							<xsl:otherwise>error</xsl:otherwise>
						</xsl:choose>
					</content-type>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="conneg-config"/>
	</p:processor>
	
	<p:choose href="#conneg-config">
		<p:when test="content-type='xml'">
			<p:processor name="oxf:identity">
				<p:input name="data" href="#data"/>		
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
		</p:when>
		<p:when test="content-type='turtle'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../models/rdf/get-ttl-ontology-current.xpl"/>
				<p:input name="data" href="#data"/>				
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='html'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/pages/ontology.xpl"/>
				<p:input name="data" href="#data"/>		
				<p:output name="data" id="model"/>
			</p:processor>
			
			<p:processor name="oxf:html-converter">
				<p:input name="data" href="#model"/>
				<p:input name="config">
					<config>
						<version>5.0</version>
						<indent>true</indent>
						<content-type>text/html</content-type>
						<encoding>utf-8</encoding>
						<indent-amount>4</indent-amount>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="406-not-acceptable.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:pipeline>
