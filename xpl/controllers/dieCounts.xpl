<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: July 2022
	Function: Evaluate URL parameters for the dieCounts API in order to construct a proper JSON error response with HTTP codes -->
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
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nomisma="http://nomisma.org/">
				
				<!-- request parameters -->
				<xsl:param name="type" select="/request/parameters/parameter[name='type']/value"/>
				<xsl:param name="dieStudy" select="/request/parameters/parameter[name='dieStudy']/value"/>
				
				<xsl:template match="/">
					<validate>
						<xsl:if test="not(matches($type, '^https?://'))">
							<error key="type">Invalid or missing coin type URI</error>
						</xsl:if>
						<xsl:if test="not(matches($dieStudy, '^https?://'))">
							<error key="dieStudy">Invalid or missing die study (corresponding to scholarly profile named graph) URI</error>
						</xsl:if>
					</validate>
				</xsl:template>
				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="conneg-config"/>
	</p:processor>
	
	<p:choose href="#conneg-config">
		<p:when test="/validate/error">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#conneg-config"/>
				<p:input name="config" href="400-bad-request.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>		
		<p:otherwise>
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../models/sparql/dieCounts.xpl"/>		
				<p:output name="data" id="model"/>
			</p:processor>
			
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#model"/>
				<p:input name="config" href="../views/serializations/sparql/dieCounts.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:pipeline>
