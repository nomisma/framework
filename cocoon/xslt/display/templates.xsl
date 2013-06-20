<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xhtml xsl xs" xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:nm="http://nomisma.org/id/"
	xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" version="2.0">

	<xsl:variable name="base">http://nomisma.org/id/</xsl:variable>

	<xsl:template match="*[string(@typeof) or string(@rel) or string(@property) and @property != 'skos:definition']">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="@typeof">
					<xsl:choose>
						<xsl:when test="contains(@typeof, ':')">
							<xsl:value-of select="@typeof"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('nm:', @typeof)"/>
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
			<xsl:if test="@xml:lang">
				<xsl:attribute name="xml:lang" select="@xml:lang"/>
			</xsl:if>
			<xsl:if test="string(@about)">
				<xsl:attribute name="rdf:about" select="concat($base, @about)"/>
			</xsl:if>
			<xsl:if test="string(@src)">
				<xsl:attribute name="rdf:resource" select="if (contains(@src, 'http://')) then @src else concat($base, @src)"/>
			</xsl:if>
			<xsl:if test="string(@resource) and not(child::*[@property])">
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
					<xsl:value-of select="@content"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string(@rel) and string(@resource) and not(child::*[@property])"/>
						<xsl:when test="string(@rel) and child::*[@property]">
							<rdf:Description>
								<xsl:if test="string(@resource)">
									<xsl:attribute name="rdf:about" select="if (contains(@resource, 'http://')) then @resource else concat($base, @resource)"/>
								</xsl:if>
								<xsl:apply-templates select="*"/>
							</rdf:Description>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="not(@resource) and not(@href) and not(@src)">
								<xsl:apply-templates/>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:if test="parent::*[string(@property)]">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="xhtml:div[@property='skos:definition']">
		<skos:definition xml:lang="{@xml:lang}">
			<xsl:value-of select="."/>
		</skos:definition>

		<xsl:if test="*[string(@rel) or string(@property)]">
			<xsl:apply-templates select="*"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="xhtml:pre">
		<xsl:apply-templates select="*"/>
	</xsl:template>
</xsl:stylesheet>
