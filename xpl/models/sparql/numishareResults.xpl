<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: January 2025
	Function: Execute a series of SPARQL queries to get the count and sample images for each identifier listed in the Solr-based browse page and subtypes on type record pages.
		This is intended to be used when the SPARQL endpoint defined in the config differs from Nomisma.org
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
	
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/nomisma/ui/sparql/numishareResults-count.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="numishareResults-count"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#numishareResults-count"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="numishareResults-count-document"/>
	</p:processor>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/nomisma/ui/sparql/numishareResults-specimens.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="numishareResults-specimens"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#numishareResults-specimens"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="numishareResults-specimens-document"/>
	</p:processor>
	
	<!-- first validate -->
	<p:choose href="#request">		
		<p:when test="not(string(/request/parameters/parameter[name='identifiers']/value))">
			<p:processor name="oxf:identity">
				<p:input name="data">
					<error>identifiers are required.</error>					
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<!-- generate identifier list -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#request"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<xsl:param name="identifiers" select="/request/parameters/parameter[name='identifiers']/value"/>
						
						<xsl:template match="/">
							<identifiers>
								<xsl:for-each select="tokenize($identifiers, '\|')">
									<identifier>
										<xsl:value-of select="normalize-space(.)"/>
									</identifier>
								</xsl:for-each>
							</identifiers>
						</xsl:template>
						
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="identifiers"/>
			</p:processor>
			
			<!-- iterate through identifiers -->
			<p:for-each href="#identifiers" select="//identifier" root="response" id="response">
				<p:processor name="oxf:identity">
					<p:input name="data" href="current()"/>
					<p:output name="data" id="id"/>
				</p:processor>
				
				<!-- execute SPARQL for hoard/object counts -->
				<p:processor name="oxf:unsafe-xslt">
					<p:input name="request" href="#request"/>
					<p:input name="config-xml" href=" ../../../config.xml"/>
					<p:input name="data" href="current()"/>
					<p:input name="query" href="#numishareResults-count-document"/>
					
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">							
							<xsl:param name="baseUri" select="doc('input:request')/request/parameters/parameter[name='baseUri']/value"/>
							<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
							<xsl:variable name="query" select="doc('input:query')"/>
							
							<xsl:template match="/">
								<xsl:variable name="uri">
									<xsl:choose>
										<xsl:when test="string($baseUri)">
											<xsl:value-of select="concat($baseUri, .)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:if test="matches(., '^https?://')">
												<xsl:value-of select="."/>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								
								<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
								
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
					<p:output name="data" id="count-url-generator-config"/>
				</p:processor>
				
				<!-- query SPARQL -->
				<p:processor name="oxf:url-generator">
					<p:input name="config" href="#count-url-generator-config"/>
					<p:output name="data" id="counts"/>
				</p:processor>
				
				<!-- execute SPARQL query for images -->
				<p:processor name="oxf:unsafe-xslt">
					<p:input name="request" href="#request"/>
					<p:input name="config-xml" href=" ../../../config.xml"/>
					<p:input name="data" href="current()"/>
					<p:input name="query" href="#numishareResults-specimens-document"/>
					
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">							
							<xsl:param name="baseUri" select="doc('input:request')/request/parameters/parameter[name='baseUri']/value"/>
							<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
							<xsl:variable name="query" select="doc('input:query')"/>
							
							<xsl:template match="/">
								<xsl:variable name="uri">
									<xsl:choose>
										<xsl:when test="string($baseUri)">
											<xsl:value-of select="concat($baseUri, .)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:if test="matches(., '^https?://')">
												<xsl:value-of select="."/>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								
								<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'typeUri', $uri))), '&amp;output=xml')"/>
								
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
					<p:output name="data" id="images-url-generator-config"/>
				</p:processor>
				
				<p:processor name="oxf:url-generator">
					<p:input name="config" href="#images-url-generator-config"/>
					<p:output name="data" id="images"/>
				</p:processor>
				
				<p:processor name="oxf:identity">
					<p:input name="data" href="aggregate('content', #id, #counts, #images)"/>
					<p:output name="data" ref="response"/>
				</p:processor>				
			</p:for-each>
			
			<p:processor name="oxf:identity">
				<p:input name="data" href="#response"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
	
</p:config>
