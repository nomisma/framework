<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

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
	
	<!-- determine whether the query is for a coin type or for a Nomisma ID -->
	<p:processor name="oxf:xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<xsl:template match="/">
					<type>
						<xsl:choose>
							<xsl:when test="/request/parameters/parameter[name='id']/value">id</xsl:when>
							<xsl:when test="/request/parameters/parameter[name='coinType']/value">coinType</xsl:when>
							<xsl:when test="/request/parameters/parameter[name='symbol']/value">symbol</xsl:when>
						</xsl:choose>
					</type>
				</xsl:template>
				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="concept-type"/>
	</p:processor>
	
	<p:processor name="oxf:xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<xsl:template match="/">
					<api>
						<xsl:value-of select="tokenize(/request/request-url, '/')[last()]"/>
					</api>
				</xsl:template>
				
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="api"/>
	</p:processor>
	
	<p:choose href="#concept-type">
		<!-- execute specific SPARQL queries for getting associated geo locations for Nomisma ID Concepts -->
		<p:when test="/type = 'id'">
			
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../rdf/get-id.xpl"/>
				<p:output name="data" id="rdf"/>
			</p:processor>
			
			<p:processor name="oxf:unsafe-xslt">		
				<p:input name="data" href="#rdf"/>		
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						
						<xsl:variable name="hasFindspots" as="item()*">
							<classes>
								<class>nmo:Denomination</class>
								<class>rdac:Family</class>
								<class>nmo:Ethnic</class>
								<class>foaf:Group</class>
								<class>nmo:Manufacture</class>
								<class>nmo:Material</class>
								<class>nmo:Mint</class>
								<class>nmo:ObjectType</class>								
								<class>foaf:Organization</class>
								<class>foaf:Person</class>
								<class>nmo:Region</class>
							</classes>
						</xsl:variable>
						
						<xsl:variable name="type" select="/rdf:RDF/*[1]/name()"/>
						
						
						<xsl:template match="/">
							<type>
								<xsl:attribute name="hasFindspots">
									<xsl:choose>
										<xsl:when test="$hasFindspots//class[text()=$type]">true</xsl:when>
										<xsl:otherwise>false</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>						
								
								<xsl:value-of select="$type"/>
							</type>
						</xsl:template>
						
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="type"/>
			</p:processor>
			
			<p:choose href="#type">
				<!-- if the ID is itself a hoard, then render from RDF -->
				<p:when test="type = 'nmo:Hoard'">
					<p:processor name="oxf:identity">
						<p:input name="data" href="#rdf"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<!-- suppress any class of object for which we do not want to render a map -->
				<p:when test="type/@hasFindspots = 'false'">
					<p:processor name="oxf:identity">
						<p:input name="data">
							<null/>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<!-- execute SPARQL query for other classes of object
				Load a SPARQL query from a text file, based on API and RDF Class -->
					<p:choose href="#api">
						<p:when test="/api = 'heatmap'">
							<p:choose href="#type">
								<p:when test="/type = 'foaf:Person'">
									<p:processor name="oxf:url-generator">
										<p:input name="config">
											<config>
												<url>oxf:/apps/nomisma/ui/sparql/heatmap_person.sparql</url>
												<content-type>text/plain</content-type>
												<encoding>utf-8</encoding>
											</config>
										</p:input>
										<p:output name="data" id="sparql-query"/>
									</p:processor>
								</p:when>
								<p:otherwise>
									<p:processor name="oxf:url-generator">
										<p:input name="config">
											<config>
												<url>oxf:/apps/nomisma/ui/sparql/heatmap_other.sparql</url>
												<content-type>text/plain</content-type>
												<encoding>utf-8</encoding>
											</config>
										</p:input>
										<p:output name="data" id="sparql-query"/>
									</p:processor>
								</p:otherwise>
							</p:choose>
						</p:when>
						<p:when test="/api = 'getFindspots'">
							<p:choose href="#type">
								<p:when test="/type = 'foaf:Person'">
									<p:processor name="oxf:url-generator">
										<p:input name="config">
											<config>
												<url>oxf:/apps/nomisma/ui/sparql/getFindspots_person.sparql</url>
												<content-type>text/plain</content-type>
												<encoding>utf-8</encoding>
											</config>
										</p:input>
										<p:output name="data" id="sparql-query"/>
									</p:processor>
								</p:when>
								<p:otherwise>
									<p:processor name="oxf:url-generator">
										<p:input name="config">
											<config>
												<url>oxf:/apps/nomisma/ui/sparql/getFindspots_other.sparql</url>
												<content-type>text/plain</content-type>
												<encoding>utf-8</encoding>
											</config>
										</p:input>
										<p:output name="data" id="sparql-query"/>
									</p:processor>
								</p:otherwise>
							</p:choose>
						</p:when>
						<p:when test="/api = 'getHoards'">
							<p:choose href="#type">
								<p:when test="/type = 'foaf:Person'">
									<p:processor name="oxf:url-generator">
										<p:input name="config">
											<config>
												<url>oxf:/apps/nomisma/ui/sparql/getHoards_person.sparql</url>
												<content-type>text/plain</content-type>
												<encoding>utf-8</encoding>
											</config>
										</p:input>
										<p:output name="data" id="sparql-query"/>
									</p:processor>
								</p:when>
								<p:otherwise>
									<p:processor name="oxf:url-generator">
										<p:input name="config">
											<config>
												<url>oxf:/apps/nomisma/ui/sparql/getHoards_other.sparql</url>
												<content-type>text/plain</content-type>
												<encoding>utf-8</encoding>
											</config>
										</p:input>
										<p:output name="data" id="sparql-query"/>
									</p:processor>
								</p:otherwise>
							</p:choose>
						</p:when>
					</p:choose>
					
					<!-- convert text into an XML document for use in XSLT -->
					<p:processor name="oxf:text-converter">
						<p:input name="data" href="#sparql-query"/>
						<p:input name="config">
							<config/>
						</p:input>
						<p:output name="data" id="sparql-query-document"/>
					</p:processor>
					
					<!-- generate the SPARQL query -->
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="#type"/>
						<p:input name="config-xml" href=" ../../../config.xml"/>
						<p:input name="query" href="#sparql-query-document"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
								<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
								<xsl:param name="api" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
								<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
								<xsl:variable name="type" select="/type"/>
								
								<xsl:variable name="classes" as="item()*">
									<classes>						
										<class prop="nmo:hasDenomination">nmo:Denomination</class>
										<class prop="?prop">rdac:Family</class>
										<class prop="?prop">nmo:Ethnic</class>						
										<class prop="nmo:hasManufacture">nmo:Manufacture</class>
										<class prop="nmo:hasMaterial">nmo:Material</class>
										<class prop="nmo:hasMint">nmo:Mint</class>
										<class prop="?prop">foaf:Organization</class>
										<class prop="?prop">foaf:Person</class>
										<class prop="nmo:hasRegion">nmo:Region</class>
									</classes>
								</xsl:variable>
								<xsl:variable name="query" select="doc('input:query')"/>
								
								<xsl:template match="/">
									<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace(replace($query, 'ID', $id), 'PROP',
										$classes//class[text()=$type]/@prop))), '&amp;output=xml')"/>
									
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
						<p:output name="data" id="url-generator-config"/>
					</p:processor>
					
					<!-- execute SPARQL query -->
					<p:processor name="oxf:url-generator">
						<p:input name="config" href="#url-generator-config"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:when test="/type = 'coinType'">
			<!-- execute SPARQL queries for findspots and hoards for coin types with the coinType HTTP request parameter -->
			<p:choose href="#api">
				<p:when test="/api = 'heatmap'">
					<p:processor name="oxf:url-generator">
						<p:input name="config">
							<config>
								<url>oxf:/apps/nomisma/ui/sparql/heatmap_coinType.sparql</url>
								<content-type>text/plain</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" id="sparql-query"/>
					</p:processor>
				</p:when>
				<p:when test="/api = 'getFindspots'">
					<p:processor name="oxf:url-generator">
						<p:input name="config">
							<config>
								<url>oxf:/apps/nomisma/ui/sparql/getFindspots_coinType.sparql</url>
								<content-type>text/plain</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" id="sparql-query"/>
					</p:processor>
				</p:when>
				<p:when test="/api = 'getHoards'">
					<p:processor name="oxf:url-generator">
						<p:input name="config">
							<config>
								<url>oxf:/apps/nomisma/ui/sparql/getHoards_coinType.sparql</url>
								<content-type>text/plain</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" id="sparql-query"/>
					</p:processor>
				</p:when>
			</p:choose>
			
			<!-- convert text into an XML document for use in XSLT -->
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#sparql-query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="sparql-query-document"/>
			</p:processor>
			
			<!-- generate the SPARQL query -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="query" href="#sparql-query-document"/>
				<p:input name="data" href=" ../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<!-- request params -->
						<xsl:param name="coinType" select="doc('input:request')/request/parameters/parameter[name='coinType']/value"/>
						
						<!-- config, SPARQL query variables -->
						<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
						<xsl:variable name="query" select="doc('input:query')"/>
						
						<xsl:template match="/">
							<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'COINTYPE', $coinType))), '&amp;output=xml')"/>
							
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
				<p:output name="data" id="url-generator-config"/>
			</p:processor>
			
			<!-- execute SPARQL query -->
			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#url-generator-config"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="/type = 'symbol'">
			<!-- execute SPARQL queries for findspots and hoards for coin types with the symbol HTTP request parameter -->
			<p:choose href="#api">
				<p:when test="/api = 'heatmap'">
					<p:processor name="oxf:url-generator">
						<p:input name="config">
							<config>
								<url>oxf:/apps/nomisma/ui/sparql/heatmap_symbol.sparql</url>
								<content-type>text/plain</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" id="sparql-query"/>
					</p:processor>
				</p:when>
				<p:when test="/api = 'getFindspots'">
					<p:processor name="oxf:url-generator">
						<p:input name="config">
							<config>
								<url>oxf:/apps/nomisma/ui/sparql/getFindspots_symbol.sparql</url>
								<content-type>text/plain</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" id="sparql-query"/>
					</p:processor>
				</p:when>
				<p:when test="/api = 'getHoards'">
					<p:processor name="oxf:url-generator">
						<p:input name="config">
							<config>
								<url>oxf:/apps/nomisma/ui/sparql/getHoards_symbol.sparql</url>
								<content-type>text/plain</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" id="sparql-query"/>
					</p:processor>
				</p:when>
			</p:choose>
			
			<!-- convert text into an XML document for use in XSLT -->
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#sparql-query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="sparql-query-document"/>
			</p:processor>
			
			<!-- generate the SPARQL query -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="query" href="#sparql-query-document"/>
				<p:input name="data" href=" ../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<!-- request params -->
						<xsl:param name="uri" select="doc('input:request')/request/parameters/parameter[name='symbol']/value"/>
						
						<!-- config, SPARQL query variables -->
						<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>
						<xsl:variable name="query" select="doc('input:query')"/>
						
						<xsl:template match="/">
							<xsl:variable name="service" select="concat($sparql_endpoint, '?query=', encode-for-uri(normalize-space(replace($query, '%URI%', $uri))), '&amp;output=xml')"/>
							
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
				<p:output name="data" id="url-generator-config"/>
			</p:processor>
			
			<!-- execute SPARQL query -->
			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#url-generator-config"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
	</p:choose>

</p:config>
