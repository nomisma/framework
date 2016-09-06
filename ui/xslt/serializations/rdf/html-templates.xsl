<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="*" mode="list-item">
		<xsl:variable name="name" select="name()"/>
		<dt>
			<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}">
				<xsl:value-of select="name()"/>
			</a>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="string(.)">
					<xsl:choose>
						<xsl:when test="name()= 'osgeo:asGeoJSON' and string-length(.) &gt; 100">
							<div id="geoJSON-fragment">
								<xsl:value-of select="substring(., 1, 100)"/>
								<xsl:text>...</xsl:text>
								<a href="#" class="toggle-geoJSON">[more]</a>
							</div>
							<div id="geoJSON-full" style="display:none">
								<span property="{name()}" xml:lang="{@xml:lang}">
									<xsl:value-of select="."/>
								</span>
								<a href="#" class="toggle-geoJSON">[less]</a>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<span property="{name()}">
								<xsl:if test="@xml:lang">
									<xsl:attribute name="xml:lang" select="@xml:lang"/>
								</xsl:if>
								<xsl:if test="@rdf:datatype">
									<xsl:attribute name="datatype" select="@rdf:datatype"/>
								</xsl:if>

								<xsl:choose>
									<xsl:when test="contains(@rdf:datatype, '#gYear')">
										<xsl:value-of select="nomisma:normalizeDate(.)"/>
									</xsl:when>
									<xsl:when test="contains(@rdf:datatype, '#gYearMonth')">
										<xsl:value-of select="nomisma:normalizeDate(.)"/>
									</xsl:when>
									<xsl:when test="contains(@rdf:datatype, '#date')">
										<xsl:value-of select="nomisma:normalizeDate(.)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</span>
							<xsl:if test="string(@xml:lang)">
								<span class="lang">
									<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
								</span>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="string(@rdf:resource)">
					<span>
						<a href="{@rdf:resource}" rel="{name()}" title="{@rdf:resource}">
							<xsl:choose>
								<xsl:when test="name()='rdf:type'">
									<xsl:variable name="uri" select="@rdf:resource"/>
									<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@rdf:resource"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</span>
				</xsl:when>
				<xsl:when test="*">
					<xsl:apply-templates select="*" mode="suburi"/>
				</xsl:when>
			</xsl:choose>
		</dd>
	</xsl:template>

	<xsl:template match="*" mode="suburi">
		<xsl:variable name="about" select="@rdf:about"/>

		<div rel="{name()}">
			<xsl:if test="string($about)">
				<xsl:attribute name="resource" select="$about"/>
			</xsl:if>

			<h3>
				<xsl:choose>
					<xsl:when test="string($about)">
						<a href="{$about}">
							<xsl:value-of select="$about"/>
						</a>
						<small>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="name()"/>
							<xsl:text>)</xsl:text>
						</small>
					</xsl:when>
					<xsl:otherwise> [_:] <small>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="name()"/>
							<xsl:text>)</xsl:text>
						</small>
					</xsl:otherwise>
				</xsl:choose>
			</h3>


			<dl class="dl-horizontal">
				<xsl:apply-templates select="*" mode="list-item">
					<xsl:sort select="name()"/>
					<xsl:sort select="@rdf:resource"/>
				</xsl:apply-templates>
			</dl>
		</div>
	</xsl:template>


</xsl:stylesheet>
