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
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="id">
						<xsl:choose>
							<xsl:when test="string(doc('input:request')/request/parameters/parameter[name='id']/value)">
								<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="doc" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
								
								<xsl:choose>
									<xsl:when test="contains($doc, '.rdf')">
										<xsl:value-of select="substring-before($doc, '.rdf')"/>
									</xsl:when>
									<xsl:when test="contains($doc, '.kml')">
										<xsl:value-of select="substring-before($doc, '.kml')"/>
									</xsl:when>							
									<xsl:when test="contains($doc, '.solr')">
										<xsl:value-of select="substring-before($doc, '.solr')"/>
									</xsl:when>
									<xsl:when test="contains($doc, '.ttl')">
										<xsl:value-of select="substring-before($doc, '.ttl')"/>
									</xsl:when>
									<xsl:when test="contains($doc, '.jsonld')">
										<xsl:value-of select="substring-before($doc, '.jsonld')"/>
									</xsl:when>
									<xsl:when test="contains($doc, '.test')">
										<xsl:value-of select="substring-before($doc, '.test')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$doc"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>						
					</xsl:variable>					
					
					<config>
						<url>
							<xsl:value-of select="concat('file://', /config/id_path, '/', $id, '.rdf')"/>
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

