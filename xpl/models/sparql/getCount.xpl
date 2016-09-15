<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
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
	
	<!-- get query from a text file on disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/nomisma/ui/sparql/typological_distribution.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="query"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">		
		<p:input name="data" href="#query"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="query-document"/>
	</p:processor>

	<!-- develop config for URL generator for the main SPARQL-based distribution query -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="query" href="#query-document"/>
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="filter" select="doc('input:request')/request/parameters/parameter[name='filter']/value"/>
				<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name='dist']/value"/>
				
				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
				<xsl:variable name="query" select="doc('input:query')"/>

				<xsl:variable name="service">
					<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%FILTERS%', $filter), '%DIST%', $dist)), '&amp;output=xml')"/>
				</xsl:variable>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="main-url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#main-url-generator-config"/>
		<p:output name="data" id="main-response"/>
	</p:processor>
	
	<!-- add in compare queries -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="compare" select="/request/parameters/parameter[name='compare']/value"/>
				
				<xsl:template match="/">
					<queries>
						<xsl:for-each select="$compare">
							<query><xsl:value-of select="."/></query>
						</xsl:for-each>
					</queries>										
				</xsl:template>
				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="compare-queries"/>
	</p:processor>
	
	<!-- when there is at least one compare query, then aggregate the compare queries with the primary query into one model -->
	<p:choose href="#compare-queries">
		<p:when test="count(//query) &gt; 0">
			<p:for-each href="#compare-queries" select="//query" root="response" id="compare-results">
				<p:processor name="oxf:unsafe-xslt">
					<p:input name="filter" href="current()"/>
					<p:input name="query" href="#query-document"/>
					<p:input name="request" href="#request"/>
					<p:input name="data" href="../../../config.xml"/>
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
							<!-- request parameters -->
							<xsl:param name="filter" select="doc('input:filter')/query"/>
							<xsl:param name="dist" select="doc('input:request')/request/parameters/parameter[name='dist']/value"/>
							
							<!-- config variables -->
							<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
							<xsl:variable name="query" select="doc('input:query')"/>
							
							<xsl:variable name="service">
								<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%FILTERS%', $filter), '%DIST%', $dist)), '&amp;output=xml')"/>
							</xsl:variable>
							
							<xsl:template match="/">
								<config>
									<url>
										<xsl:value-of select="$service"/>
									</url>
									<content-type>application/xml</content-type>
									<encoding>utf-8</encoding>
								</config>
							</xsl:template>
						</xsl:stylesheet>
					</p:input>
					<p:output name="data" id="compare-url-generator-config"/>
				</p:processor>
				
				<!-- get the data from fuseki -->
				<p:processor name="oxf:url-generator">
					<p:input name="config" href="#compare-url-generator-config"/>
					<p:output name="data" ref="compare-results"/>
				</p:processor>
			</p:for-each>
			
			<p:processor name="oxf:identity">
				<p:input name="data" href="aggregate('content', #main-response, #compare-results)"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:identity">
				<p:input name="data" href="#main-response"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
