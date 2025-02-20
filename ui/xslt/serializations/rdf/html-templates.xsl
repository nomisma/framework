<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:org="http://www.w3.org/ns/org#" xmlns:nomisma="http://nomisma.org/"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:prov="http://www.w3.org/ns/prov#"
	xmlns:bio="http://purl.org/vocab/bio/0.1/" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/"
	xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/" exclude-result-prefixes="#all" version="2.0">

	<!-- human readable templates for ID or other concept scheme RDF serializations. mode="type" is for general output from SPARQL CONSTRUCT or DESCRIBE -->
	<xsl:template match="*" mode="human-readable">
		<xsl:param name="mode"/>

		<div>
			<xsl:if test="@rdf:about">
				<xsl:attribute name="about" select="@rdf:about"/>
				<xsl:attribute name="typeof" select="name()"/>
				<xsl:if test="contains(@rdf:about, '#this')">
					<xsl:attribute name="id">#this</xsl:attribute>
				</xsl:if>
			</xsl:if>

			<xsl:element
				name="{if (name()='prov:Activity') then 'h4' else if (name() = 'dcterms:ProvenanceStatement') then 'h3' else if (not(parent::rdf:RDF)) then 'h3' else if(position()=1) then 'h2' else 'h3'}">
				<!-- display a label based on the URI if there is an @rdf:about, otherwise formulate a blank node label -->

				<xsl:choose>
					<xsl:when test="@rdf:about">
						<xsl:choose>
							<xsl:when test="contains(@rdf:about, '#')">
								<xsl:value-of select="concat('#', substring-after(@rdf:about, '#'))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="skos:prefLabel[@xml:lang = 'en']"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>[blank node]</xsl:otherwise>
				</xsl:choose>


				<small>
					<xsl:text> (</xsl:text>
					<a href="{concat(namespace-uri(.), local-name())}" title="{name()}">
						<xsl:value-of select="nomisma:normalizeCurie(name(), $lang)"/>
					</a>
					<xsl:if test="rdf:type">
						<xsl:text>, </xsl:text>
						<xsl:apply-templates select="rdf:type" mode="normalize-class"/>
					</xsl:if>
					<xsl:text>)</xsl:text>
				</small>
			</xsl:element>

			<xsl:if test="@rdf:about">
				<p>
					<strong>Canonical URI: </strong>
					<code>
						<a href="{@rdf:about}">
							<xsl:value-of select="@rdf:about"/>
						</a>
					</code>
				</p>
			</xsl:if>
			
			<xsl:apply-templates select="foaf:thumbnail"/>


			<xsl:if test="skos:prefLabel">
				<div class="section">
					<h4>Labels</h4>
					<dl class="dl-horizontal">
						<dt>
							<a href="{concat($namespaces//namespace[@prefix='skos']/@uri, 'prefLabel')}" title="skos:prefLabel">
								<xsl:value-of select="nomisma:normalizeCurie('skos:prefLabel', $lang)"/>
							</a>
						</dt>
						<dd>
							<xsl:apply-templates select="skos:prefLabel[lang('en') or lang('fr') or lang('de') or lang('el') or lang('it') or lang('es') or not(@xml:lang)]"
								mode="prefLabel"/>

							<!-- additional labels -->
							<xsl:if test="skos:prefLabel[not(lang('en') or lang('fr') or lang('de') or lang('el') or lang('it') or lang('es') or not(@xml:lang))]">
								<span style="margin-left:20px">
									<i>Additional labels</i>
									<a href="#" class="toggle-button" id="toggle-prefLabels" title="Click to hide or show additional labels">
										<span class="glyphicon glyphicon-triangle-right"/>
									</a>
								</span>
							</xsl:if>
							<div style="display:none" id="prefLabels">
								<xsl:apply-templates
									select="skos:prefLabel[not(lang('en') or lang('fr') or lang('de') or lang('el') or lang('it') or lang('es') or not(@xml:lang))]"
									mode="prefLabel">
									<xsl:sort select="@xml:lang"/>
								</xsl:apply-templates>
							</div>
						</dd>



						<xsl:apply-templates select="skos:altLabel" mode="human-readable">
							<xsl:sort select="@xml:lang"/>
						</xsl:apply-templates>
					</dl>
				</div>
			</xsl:if>

			<xsl:if test="skos:definition">
				<div class="section">
					<h4>Definitions</h4>

					<dl class="dl-horizontal">
						<xsl:apply-templates select="skos:definition" mode="human-readable"/>

					</dl>

				</div>
			</xsl:if>

			<xsl:if test="crm:P106_is_composed_of">
				<xsl:variable name="name">crm:P106_is_composed_of</xsl:variable>

				<dt>
					<a href="{concat($namespaces//namespace[@prefix='crm']/@uri, 'P106_is_composed_of')}" title="crm:P106_is_composed_of">
						<xsl:value-of select="nomisma:normalizeCurie('crm:P106_is_composed_of', $lang)"/>
					</a>
				</dt>
				<dd>
					<xsl:for-each select="crm:P106_is_composed_of">
						<xsl:if test="position() = last() and not(position() = 1)">
							<xsl:text> and</xsl:text>
						</xsl:if>
						<xsl:if test="position() &gt; 1">
							<xsl:text> </xsl:text>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="@rdf:resource">
								<a href="{@rdf:resource}">
									<xsl:value-of select="@rdf:resource"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="not(position() = last()) and (count(../crm:P106_is_composed_of) &gt; 2)">
							<xsl:text>,</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</dd>
			</xsl:if>

			<xsl:apply-templates select="geo:location" mode="human-readable"/>

			<xsl:if test="org:hasMembership">
				<div class="section">
					<h4>Roles</h4>

					<xsl:for-each select="org:hasMembership">
						<xsl:variable name="position" select="position()"/>
						<xsl:variable name="uri" select="@rdf:resource"/>
						<xsl:apply-templates select="//org:Membership[@rdf:about = $uri]" mode="human-readable">
							<xsl:with-param name="position" select="$position"/>
						</xsl:apply-templates>
					</xsl:for-each>
				</div>
			</xsl:if>

			<xsl:if test="bio:birth or bio:death">
				<div class="section">
					<h4>Biographical Information</h4>
					<dl class="dl-horizontal">
						<xsl:apply-templates select="bio:birth" mode="human-readable"/>
						<xsl:apply-templates select="bio:death" mode="human-readable"/>
					</dl>
				</div>
			</xsl:if>

			<xsl:if test="skos:exactMatch or skos:closeMatch or skos:related or skos:broader or skos:inScheme">
				<div class="section">
					<h4>Relations</h4>

					<dl class="dl-horizontal">
						<xsl:apply-templates select="skos:exactMatch | skos:broader | skos:closeMatch | skos:related | skos:inScheme" mode="human-readable">
							<xsl:sort select="local-name()"/>
							<xsl:sort select="@rdf:resource"/>
						</xsl:apply-templates>
					</dl>
				</div>
			</xsl:if>

			<xsl:if test="dcterms:isPartOf or dcterms:source or foaf:homepage or foaf:thumbnail">
				<div class="section">
					<h4>Miscellaneous</h4>

					<dl class="dl-horizontal">
						<xsl:apply-templates select="dcterms:isPartOf | dcterms:source | foaf:homepage | foaf:thumbnail" mode="human-readable">
							<xsl:sort select="local-name()"/>
							<xsl:sort select="@rdf:resource"/>
						</xsl:apply-templates>
					</dl>
				</div>
			</xsl:if>

			<!-- TODO: location, miscellaneous -->
		</div>
	</xsl:template>

	<!-- date rendering -->
	<xsl:template match="nmo:hasStartDate | nmo:hasEndDate" mode="human-readable">
		<dt>
			<a href="{concat(namespace-uri(), local-name())}" title="{name()}">
				<xsl:value-of select="nomisma:normalizeCurie(name(), $lang)"/>
			</a>
		</dt>
		<dd>
			<span property="{name()}" content="{.}" datatype="xsd:gYear">
				<xsl:value-of select="nomisma:normalizeYear(.)"/>
			</span>
		</dd>
	</xsl:template>

	<xsl:template match="geo:location" mode="human-readable">
		<xsl:variable name="uri" select="@rdf:resource"/>

		<xsl:apply-templates select="//geo:SpatialThing[@rdf:about = $uri]" mode="human-readable"/>
	</xsl:template>

	<xsl:template match="bio:birth | bio:death" mode="human-readable">
		<xsl:variable name="uri" select="@rdf:resource"/>
		<xsl:variable name="class" select="concat(upper-case(substring(local-name(), 1, 1)), substring(local-name(), 2))"/>

		<xsl:apply-templates select="//*[local-name() = $class][@rdf:about = $uri]" mode="human-readable"/>
	</xsl:template>

	<xsl:template match="bio:Birth | bio:Death" mode="human-readable">
		<dt>
			<a href="{concat(namespace-uri(), local-name())}" title="{name()}">
				<xsl:value-of select="nomisma:normalizeCurie(name(), $lang)"/>
			</a>
		</dt>

		<xsl:apply-templates select="dcterms:date" mode="human-readable"/>
	</xsl:template>

	<xsl:template match="dcterms:date" mode="human-readable">
		<dd>
			<span property="{name()}" content="{.}" datatype="{@rdf:datatype}">
				<xsl:value-of select="nomisma:normalizeDate(.)"/>
			</span>
		</dd>
	</xsl:template>

	<xsl:template match="geo:SpatialThing" mode="human-readable">
		<div class="section">
			<h4>Geospatial Data</h4>
			
			<strong>URI: </strong>
			<code>
				<a href="{@rdf:about}">
					<xsl:value-of select="@rdf:about"/>
				</a>
			</code>
			
			<dl class="dl-horizontal">
				<xsl:apply-templates select="geo:lat | geo:long | osgeo:asGeoJSON | dcterms:isPartOf" mode="human-readable"/>
			</dl>
		</div>
	</xsl:template>

	<xsl:template match="org:Membership" mode="human-readable">
		<xsl:param name="position"/>
		
		<div property="org:hasMembership">
			<h5>Membership <xsl:value-of select="$position"/></h5>

			<strong>URI: </strong>
			<code>
				<a href="{@rdf:about}">
					<xsl:value-of select="@rdf:about"/>
				</a>
			</code>

			<dl class="dl-horizontal" typeof="org:Membership">
				<xsl:apply-templates select="rdfs:label[@xml:lang = 'en']" mode="human-readable"/>
				<xsl:apply-templates select="rdfs:label[not(@xml:lang = 'en')]" mode="human-readable"/>
				
				<xsl:apply-templates select="org:role | org:organization" mode="human-readable"/>

				<xsl:apply-templates select="nmo:hasStartDate" mode="human-readable"/>
				<xsl:apply-templates select="nmo:hasEndDate" mode="human-readable"/>
			</dl>
		</div>
	</xsl:template>

	<xsl:template match="skos:prefLabel" mode="prefLabel">
		<span property="{name()}" xml:lang="{@xml:lang}">
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

	<xsl:template match="skos:definition | rdfs:label" mode="human-readable">
		<dt>
			<xsl:value-of select="@xml:lang"/>
		</dt>
		<dd property="{name()}" lang="{@xml:lang}">
			<xsl:value-of select="."/>
		</dd>
	</xsl:template>

	<xsl:template match="osgeo:asGeoJSON" mode="human-readable">
		<dt>
			<a href="{concat(namespace-uri(), local-name())}" title="{name()}">
				<xsl:value-of select="nomisma:normalizeCurie(name(), $lang)"/>
			</a>
		</dt>
		<dd>
			<xsl:call-template name="render_geojson"/>
		</dd>
	</xsl:template>

	<xsl:template match="skos:* | foaf:homepage | foaf:thumbnail | dcterms:source | dcterms:isPartOf | org:role | org:organization | geo:lat | geo:long"
		mode="human-readable">
		<dt>
			<a href="{concat(namespace-uri(), local-name())}" title="{name()}">
				<xsl:value-of select="nomisma:normalizeCurie(name(), $lang)"/>
			</a>
		</dt>
		<dd property="{name()}">
			<xsl:if test="@xml:lang">
				<xsl:attribute name="lang" select="@xml:lang"/>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="@rdf:resource">
					<a href="{@rdf:resource}">
						<xsl:value-of select="@rdf:resource"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:if test="string(@xml:lang)">
				<span class="lang">
					<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
				</span>
			</xsl:if>
		</dd>
	</xsl:template>

	<xsl:template match="rdf:type" mode="normalize-class">
		<xsl:variable name="uri" select="@rdf:resource"/>
		<xsl:variable name="curie"
			select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>

		<a href="{@rdf:resource}" title="{$curie}">
			<xsl:value-of select="nomisma:normalizeCurie($curie, $lang)"/>
		</a>

		<xsl:if test="not(position() = last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

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

			<xsl:element
				name="{if (name()='prov:Activity') then 'h4' else if (name() = 'dcterms:ProvenanceStatement') then 'h3' else if (not(parent::rdf:RDF)) then 'h3' else if(position()=1) then 'h2' else 'h3'}">
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
					<xsl:choose>
						<xsl:when test="@rdf:parseType">
							<xsl:value-of select="@rdf:parseType"/>
						</xsl:when>
						<xsl:otherwise>
							<a href="{concat(namespace-uri(.), local-name())}">
								<xsl:value-of select="name()"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>)</xsl:text>
				</small>
			</xsl:element>

			<dl class="dl-horizontal">
				<xsl:if test="not($mode = 'sparql')">
					<xsl:if test="skos:prefLabel">
						<dt>
							<a href="{concat($namespaces//namespace[@prefix='skos']/@uri, 'prefLabel')}" title="skos:prefLabel">skos:prefLabel</a>
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

				<!-- constituent letters -->
				<xsl:if test="crm:P106_is_composed_of">
					<xsl:variable name="name">crm:P106_is_composed_of</xsl:variable>

					<dt>
						<a href="{concat($namespaces//namespace[@prefix='crm']/@uri, 'P106_is_composed_of')}" title="crm:P106_is_composed_of"
							>crm:P106_is_composed_of</a>
					</dt>
					<dd>
						<xsl:for-each select="crm:P106_is_composed_of">
							<xsl:if test="position() = last()">
								<xsl:text> and</xsl:text>
							</xsl:if>
							<xsl:text> </xsl:text>
							<xsl:choose>
								<xsl:when test="@rdf:resource">
									<a href="{@rdf:resource}">
										<xsl:value-of select="@rdf:resource"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="not(position() = last()) and (count(../crm:P106_is_composed_of) &gt; 2)">
								<xsl:text>,</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</dd>
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
			<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}" title="{name()}">
				<xsl:value-of select="name()"/>
			</a>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="@rdf:parseType = 'Resource'">
					<xsl:apply-templates select="self::node()" mode="type"/>
				</xsl:when>
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
	<xsl:template match="foaf:thumbnail">
		<xsl:choose>
			<xsl:when test="../foaf:homepage">
				<a href="{../foaf:homepage/@rdf:resource}">
					<img src="{@rdf:resource}" rel="{name()}" alt="Logo" style="max-width:200px;max-height:60px"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<img src="{@rdf:resource}" rel="{name()}" alt="Logo" style="max-width:200px;max-height:60px"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- alternative display for constituent letters above -->
	<xsl:template match="crm:P106_is_composed_of" mode="list-item"/>

	<!-- suppress SVG image data objects from the standard serialization -->
	<xsl:template match="crm:P165i_is_incorporated_in[crmdig:D1_Digital_Object]" mode="list-item"/>

	<!-- special view for SVG files for symbols and monograms -->
	<xsl:template match="crmdig:D1_Digital_Object">
		<tr>
			<td>
				<img src="{@rdf:about}" alt="SVG Image of Symbol" style="width:100%"/>
			</td>
			<td>
				<dl class="dl-horizontal">
					<dt>URI</dt>
					<dd>
						<a href="{@rdf:about}">
							<xsl:value-of select="@rdf:about"/>
						</a>
					</dd>

					<xsl:apply-templates select="*" mode="list-item"/>
				</dl>
			</td>
		</tr>
	</xsl:template>

	<xsl:template name="render_geojson">
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
	</xsl:template>
</xsl:stylesheet>
