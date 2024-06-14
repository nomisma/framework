<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: June 2024
	Function: Serialize SPARQL results from aggregate-places.xpl into the JSON metadmodel conforming to Linked Places JSON-LD
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
	
	<!-- 
		Note: Orbeon URL generator will not properly digest XML from HTTP attachments		
	-->
	
	<!-- parse all possible period URIs and generate a list of distinct Getty AAT ones -->
	<!--<p:processor name="oxf:xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#">
				
				<xsl:variable name="periods" as="element()*">
					<all-periods>
						<xsl:for-each
							select="distinct-values(descendant::res:binding[@name = 'periods']/res:literal)">
							<xsl:for-each select="tokenize(., ' ')">
								<period>
									<xsl:value-of select="."/>
								</period>
							</xsl:for-each>
						</xsl:for-each>
					</all-periods>
				</xsl:variable>
				
				<xsl:template match="/">
					<periods>
						<xsl:for-each select="distinct-values($periods//period[contains(., 'vocab.getty.edu')])">
							<period>
								<xsl:value-of select="."/>
							</period>
						</xsl:for-each>
					</periods>
				</xsl:template>
				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="periods"/>
	</p:processor>
	
	<!-\- iterate through Getty AAT URIs and extract RDF -\->
	<p:for-each href="#periods" select="//period" root="aggregate" id="rdf">
		<p:processor name="oxf:unsafe-xslt">
			<p:input name="data" href="current()"/>
			<p:input name="config">
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
					xmlns:xxf="http://www.orbeon.com/oxf/pipeline">
					
					<xsl:template match="/">
						<config>
							<url>
								<xsl:value-of select="concat('http://vocab.getty.edu/download/rdf?uri=', ., '.rdf')"/>
							</url>
							<mode>xml</mode>
							<content-type>application/xml</content-type>
							<encoding>utf-8</encoding>
						</config>
					</xsl:template>
				</xsl:stylesheet>
			</p:input>
			<p:output name="data" id="generator-config"/>
		</p:processor>
		
		<p:processor name="oxf:url-generator">
			<p:input name="config" href="#generator-config"/>
			<p:output name="data" ref="rdf"/>
		</p:processor>
	</p:for-each>
	
	<p:processor name="oxf:identity">
		<p:input name="data" href="#rdf"/>
		<p:output name="data" ref="data"/>
	</p:processor>-->

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<!--<p:input name="rdf" href="#rdf"/>-->
		<p:input name="data" href="#data"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/sparql/linked-places.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/json</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
