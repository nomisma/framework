<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">
	
	<p:param type="input" name="file"/>
	<p:param type="output" name="data"/>	
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>	
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				
				<xsl:template match="/">
					<xsl:variable name="request-url" select="doc('input:request')/request/request-url"/>
					<xsl:variable name="pieces" select="tokenize($request-url, '/')"/>
					<xsl:variable name="scheme" select="$pieces[count($pieces) - 1]"/>					
					
					<xsl:variable name="doc">
						<xsl:choose>
							<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='id']/value)">
								<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="string-length($pieces[last()]) &gt; 0">
										<xsl:choose>
											<xsl:when test="contains($pieces[last()], '.rdf')">
												<xsl:value-of select="substring-before($pieces[last()], '.rdf')"/>
											</xsl:when>
											<xsl:when test="contains($pieces[last()], '.kml')">
												<xsl:value-of select="substring-before($pieces[last()], '.kml')"/>
											</xsl:when>
											<xsl:when test="contains($pieces[last()], '.ttl')">
												<xsl:value-of select="substring-before($pieces[last()], '.ttl')"/>
											</xsl:when>
											<xsl:when test="contains($pieces[last()], '.jsonld')">
												<xsl:value-of select="substring-before($pieces[last()], '.jsonld')"/>
											</xsl:when>				
											<xsl:when test="contains($pieces[last()], '.solr')">
												<xsl:value-of select="substring-before($pieces[last()], '.solr')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$pieces[last()]"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$scheme"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>				
					
					<config>
						<url>
							<xsl:choose>
								<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='id']/value)">
									<xsl:value-of select="concat('file://', /config/data_path, '/id/', $doc, '.rdf')"/>
								</xsl:when>
								<xsl:when test="string-length($pieces[last()]) &gt; 0">
									<xsl:value-of select="concat('file://', /config/data_path, '/', $scheme, '/', $doc, '.rdf')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('file://', /config/data_path, '/', $doc, '.rdf')"/>
								</xsl:otherwise>
							</xsl:choose>
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

