<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Function: Evaluate Accept HTTP header and perform the correct content negotiation -->
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
				<xsl:output indent="yes"/>
				
				<xsl:variable name="content-type" select="//header[name[.='accept']]/value"/>
				
				<xsl:template match="/">
					<content-type>
						<xsl:variable name="pieces" select="tokenize($content-type, ';')"/>
						
						<!-- normalize space in fragments in order to support better parsing for content negotiation -->
						<xsl:variable name="accept-fragments" as="item()*">
							<nodes>
								<xsl:for-each select="$pieces">
									<node>
										<xsl:value-of select="normalize-space(.)"/>
									</node>
								</xsl:for-each>
							</nodes>
						</xsl:variable>
						
						<xsl:choose>
							<xsl:when test="count($accept-fragments/node) &gt; 1">
								
								<!-- validate profiles, only linked.art profile for JSON-LD is supported at the moment, to differentiate from the default Nomisma.org JSON-LD -->
								<xsl:choose>
									<xsl:when test="$accept-fragments/node[starts-with(., 'profile=')]">
										<!-- parse the profile URI -->
										<xsl:variable name="profile" select="replace(substring-after($accept-fragments/node[starts-with(., 'profile=')][1], '='), '&#x022;', '')"/>
										
										<xsl:choose>
											<!-- only allow the linked.art profile if the content-type is validated to JSON-LD -->
											<xsl:when test="nomisma:resolve-content-type($accept-fragments/node[1]) = 'json-ld'">												
												<xsl:choose>
													<xsl:when test="$profile = 'https://linked.art/ns/v1/linked-art.json'">linked-art</xsl:when>
													<xsl:otherwise>json-ld</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="nomisma:resolve-content-type($accept-fragments/node[1])"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="nomisma:resolve-content-type($accept-fragments/node[1])"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<!--<xsl:choose>
									<xsl:when test="$accept-profile = '&lt;https://linked.art/ns/v1/linked-art.json&gt;'">linked-art</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="nomisma:resolve-content-type($content-type)"/>
									</xsl:otherwise>
								</xsl:choose>-->
								
								<xsl:value-of select="nomisma:resolve-content-type($content-type)"/>
							</xsl:otherwise>
						</xsl:choose>
					</content-type>
				</xsl:template>
				
				<xsl:function name="nomisma:resolve-content-type">
					<xsl:param name="content-type"/>
					
					<xsl:choose>
						<xsl:when test="$content-type='application/ld+json'">json-ld</xsl:when>
						<xsl:when test="$content-type='application/vnd.geo+json'">geojson</xsl:when>
						<xsl:when test="$content-type='application/vnd.google-earth.kml+xml'">kml</xsl:when>
						<xsl:when test="$content-type='application/rdf+xml' or $content-type='application/xml' or $content-type='text/xml'">xml</xsl:when>
						<xsl:when test="$content-type='text/turtle'">turtle</xsl:when>
						<xsl:when test="contains($content-type, 'text/html') or $content-type='*/*' or not(string($content-type))">html</xsl:when>
						<xsl:otherwise>error</xsl:otherwise>
					</xsl:choose>
				</xsl:function>
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
		<p:when test="content-type='linked-art'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../views/serializations/rdf/linkedart-json-ld.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='geojson'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../views/serializations/rdf/geojson.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='json-ld'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="call-rdflib.xpl"/>									
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='turtle'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="call-rdflib.xpl"/>									
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='kml'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/rdf/kml.xpl"/>
				<p:input name="data" href="#data"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='html'">
			<!-- read the data. if the RDF contains the dcterms:isReplacedBy property, then create an HTTP 303 redirect -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<xsl:template match="/">
							<redirect>
								<xsl:choose>
									<xsl:when test="descendant::dcterms:isReplacedBy/@rdf:resource">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</redirect>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="redirect-config"/>
			</p:processor>
			
			<p:choose href="#redirect-config">
				<p:when test="redirect='true'">
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="303-redirect.xpl"/>		
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>	
						<p:input name="config" href="../views/serializations/rdf/html.xpl"/>						
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
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
