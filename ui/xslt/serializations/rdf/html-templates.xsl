<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:org="http://www.w3.org/ns/org#" xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:prov="http://www.w3.org/ns/prov#" exclude-result-prefixes="#all" version="2.0">

	<!-- generic template for rendering top-level objects -->
	<xsl:template match="*" mode="type">
		<xsl:param name="mode"/>
		
		<div>
			<xsl:attribute name="typeof" select="name()"/>
			<xsl:if test="@rdf:about">
				<xsl:attribute name="about" select="@rdf:about"/>
				<xsl:if test="contains(@rdf:about, '#this')">
					<xsl:attribute name="id">#this</xsl:attribute>
				</xsl:if>
			</xsl:if>
			
			<xsl:element name="{if (name()='prov:Activity') then 'h4' else if (name() = 'dcterms:ProvenanceStatement') then 'h3' else if (not(parent::rdf:RDF)) then 'h3' else if(position()=1) then 'h2' else 'h3'}">
				<!-- display a label based on the URI if there is an @rdf:about, otherwise formulate a blank node label -->
				<xsl:choose>
					<xsl:when test="@rdf:about">
						<a href="{@rdf:about}">
							<!-- display the full URI if the template is called from the SPARQL HTML results page -->
							<xsl:choose>
								<xsl:when test="$mode = 'sparql'">
									<xsl:value-of select="@rdf:about"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="contains(@rdf:about, '#')">
											<xsl:value-of select="concat('#', substring-after(@rdf:about, '#'))"/>
										</xsl:when>
										<xsl:when test="contains(@rdf:about, 'geonames.org')">
											<xsl:value-of select="@rdf:about"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="tokenize(@rdf:about, '/')[last()]"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>[_:]</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				
				<small>
					<xsl:text> (</xsl:text>
					<a href="{concat(namespace-uri(.), local-name())}">
						<xsl:value-of select="name()"/>
					</a>
					<xsl:text>)</xsl:text>
				</small>
			</xsl:element>

			<dl class="dl-horizontal">
				<xsl:if test="not($mode = 'sparql')">
					<xsl:if test="skos:prefLabel">
						<dt>
							<a href="{concat($namespaces//namespace[@prefix='skos']/@uri, 'prefLabel')}">skos:prefLabel</a>
						</dt>
						<dd>
							<xsl:apply-templates select="skos:prefLabel" mode="prefLabel">
								<xsl:sort select="@xml:lang"/>
							</xsl:apply-templates>
						</dd>
					</xsl:if>
					<xsl:apply-templates select="skos:definition" mode="list-item">
						<xsl:sort select="@xml:lang"/>
					</xsl:apply-templates>					
				</xsl:if>
				
				
				<!-- choose the method of sorting -->
				<xsl:choose>
					<xsl:when test="name() = 'dcterms:ProvenanceStatement'">
						<xsl:apply-templates mode="list-item">
							<xsl:sort select="xs:dateTime(prov:Activity/prov:atTime)"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<!-- display all properties sorted in order in the SPARQL HTML page, otherwise display other properties after the prefLabels and definitions -->
						<xsl:choose>
							<xsl:when test="$mode = 'sparql'">
								<xsl:apply-templates mode="list-item">
									<xsl:sort select="name()"/>
									<xsl:sort select="@rdf:resource"/>
									<xsl:sort select="@xml:lang"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="*[not(name() = 'skos:prefLabel') and not(name() = 'skos:definition')]" mode="list-item">
									<xsl:sort select="name()"/>
									<xsl:sort select="@rdf:resource"/>
									<xsl:sort select="@xml:lang"/>
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>

			</dl>
		</div>
	</xsl:template>
	
	<!-- triples under a top-level data object -->
	<xsl:template match="*" mode="list-item">
		<xsl:variable name="name" select="name()"/>
		<dt>
			<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}">
				<xsl:value-of select="name()"/>
			</a>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="child::*">
					<!-- handle nested blank nodes (applies to provenance) -->
					<xsl:apply-templates select="child::*" mode="type"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string(.)">
							<xsl:choose>
								<xsl:when test="name() = 'osgeo:asGeoJSON' and string-length(.) &gt; 100">
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
									<span property="{name()}" xml:lang="{@xml:lang}">
										<xsl:value-of select="."/>
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
										<xsl:when test="name() = 'rdf:type'">
											<xsl:variable name="uri" select="@rdf:resource"/>
											<xsl:value-of
												select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
											/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="@rdf:resource"/>
										</xsl:otherwise>
									</xsl:choose>
								</a>
							</span>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</dd>
	</xsl:template>
	
	<!-- templates for specific RDF properties -->
	<xsl:template match="skos:prefLabel" mode="prefLabel">
		<span property="{name()}" lang="{@xml:lang}">
			<xsl:value-of select="."/>
		</span>
		<xsl:if test="string(@xml:lang)">
			<span class="lang">
				<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
			</span>
		</xsl:if>
		<xsl:if test="not(position() = last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<!-- display thumbnail -->
	<xsl:template match="foaf:thumbnail" mode="list-item">
		<xsl:variable name="name" select="name()"/>
		<dt>
			<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}">
				<xsl:value-of select="name()"/>
			</a>
		</dt>
		<dd>			
			<xsl:choose>
				<xsl:when test="../foaf:homepage">
					<a href="{../foaf:homepage/@rdf:resource}">
						<img src="{@rdf:resource}" rel="{name()}" alt="Logo" style="max-width:100%"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<img src="{@rdf:resource}" rel="{name()}" alt="Logo" style="max-width:100%"/>
				</xsl:otherwise>
			</xsl:choose>
		</dd>		
	</xsl:template>
</xsl:stylesheet>
