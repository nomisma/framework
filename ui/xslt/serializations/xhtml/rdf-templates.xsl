<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xhtml xsl xs"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" version="2.0">
	<xsl:variable name="base">http://nomisma.org/id/</xsl:variable>

	<xsl:template match="*[string(@type) or string(@rel) or string(@property)]">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="@type">
					<xsl:choose>
						<xsl:when test="not(contains(@type, ':'))">
							<xsl:value-of select="concat('nm:', @type)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@type"/>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:when>
				<xsl:when test="@rel">
					<xsl:choose>
						<xsl:when test="contains(@rel, ':')">
							<xsl:value-of select="@rel"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('nm:', @rel)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="@property">
					<xsl:choose>
						<xsl:when test="contains(@property, ':')">
							<xsl:value-of select="@property"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('nm:', @property)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:element name="{$element}">
			<xsl:if test="not(child::*) and text()">
				<xsl:attribute name="xml:lang" select="if(string(@xml:lang)) then @xml:lang else 'en'"/>
			</xsl:if>
			<xsl:if test="string(@about)">
				<xsl:attribute name="rdf:about" select="concat($base, @about)"/>
			</xsl:if>
			<xsl:if test="string(@resource)">
				<xsl:attribute name="rdf:resource" select="if (contains(@resource, 'http://')) then @resource else concat($base, @resource)"/>
			</xsl:if>
			<xsl:if test="string(@href)">
				<xsl:attribute name="rdf:resource" select="if (contains(@href, 'http://')) then @href else concat($base, @href)"/>
			</xsl:if>
			<xsl:if test="string(@datatype)">
				<xsl:attribute name="rdf:datatype" select="replace(@datatype, 'xsd:', 'http://www.w3.org/2001/XMLSchema#')"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@content">
					<xsl:value-of select="if(number(@content)) then format-number(@content, '0000') else @content"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string(@rel) and child::*">
							<rdf:Description>
								<xsl:apply-templates/>
							</rdf:Description>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="not(@resource) and not(@href)">
								<xsl:apply-templates/>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="xhtml:pre">
		<xsl:apply-templates select="*"/>
	</xsl:template>
</xsl:stylesheet>
