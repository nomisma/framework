<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:org="http://www.w3.org/ns/org#" xmlns:nmo="http://nomisma.org/ontology#"
	xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#" exclude-result-prefixes="xsl xs" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="rdf:RDF">
		<xsl:for-each select="*">
			<xsl:result-document method="xml" href="/usr/local/projects/nomisma-data/id/{substring-after(@rdf:about, 'id/')}.rdf">
				<rdf:RDF>
					<xsl:apply-templates select="current()"/>
				</rdf:RDF>
			</xsl:result-document>
		</xsl:for-each>
		<!--<rdf:RDF>
			<xsl:apply-templates select="*"/>
		</rdf:RDF>-->
	</xsl:template>

	<!-- deal with geographic -->
	<xsl:template match="nm:nomisma_region|nm:head_1911_region|nm:region">
		<xsl:element name="nmo:Region" namespace="http://nomisma.org/ontology#">
			<xsl:attribute name="rdf:about" select="@rdf:about"/>
			<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
			<xsl:apply-templates/>
			<xsl:if test="descendant::geo:lat">
				<geo:location rdf:resource="{concat(@rdf:about, '#this')}"/>
			</xsl:if>
		</xsl:element>
		<xsl:if test="descendant::geo:lat">
			<geo:SpatialThing rdf:about="{concat(@rdf:about, '#this')}">
				<xsl:if test="descendant::geo:lat">
					<geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float">
						<xsl:value-of select="descendant::geo:lat"/>
					</geo:lat>
				</xsl:if>
				<xsl:if test="descendant::geo:long">
					<geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float">
						<xsl:value-of select="descendant::geo:long"/>
					</geo:long>
				</xsl:if>
				<xsl:if test="nm:uncertain_value">
					<un:hasUncertainty rdf:resource="http://nomisma.org/id/uncertain_value"/>
				</xsl:if>
			</geo:SpatialThing>
		</xsl:if>
	</xsl:template>

	<!-- generic types -->
	<xsl:template
		match="nm:denomination[parent::rdf:RDF]|nm:mint[parent::rdf:RDF]|nm:material[parent::rdf:RDF]|nm:manufacture[parent::rdf:RDF]|nm:collection[parent::rdf:RDF]|nm:ethnic[parent::rdf:RDF]">
		<xsl:element name="nmo:{concat(upper-case(substring(local-name(), 1, 1)), substring(local-name(), 2))}" namespace="http://nomisma.org/ontology#">
			<xsl:attribute name="rdf:about" select="@rdf:about"/>
			<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
			<xsl:apply-templates/>
			<xsl:if test="descendant::geo:lat">
				<geo:location rdf:resource="{concat(@rdf:about, '#this')}"/>
			</xsl:if>
		</xsl:element>
		<xsl:if test="descendant::geo:lat">
			<geo:SpatialThing rdf:about="{concat(@rdf:about, '#this')}">
				<xsl:if test="descendant::geo:lat">
					<geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float">
						<xsl:value-of select="descendant::geo:lat"/>
					</geo:lat>
				</xsl:if>
				<xsl:if test="descendant::geo:long">
					<geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float">
						<xsl:value-of select="descendant::geo:long"/>
					</geo:long>
				</xsl:if>
				<xsl:if test="nm:uncertain_value">
					<un:hasUncertainty rdf:resource="http://nomisma.org/id/uncertain_value"/>
				</xsl:if>
			</geo:SpatialThing>
		</xsl:if>
	</xsl:template>



	<xsl:template match="nm:field_of_numismatics|nm:numismatic_term|nm:coin_wear|nm:object_type|nm:type_series">
		<xsl:variable name="pieces" select="tokenize(local-name(), '_')"/>
		<xsl:variable name="element">
			<xsl:for-each select="$pieces">
				<xsl:value-of select="concat(upper-case(substring(., 1, 1)), substring(., 2))"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="uri" select="@rdf:about"/>

		<xsl:choose>
			<!-- convert some to roles -->
			<xsl:when test="contains($uri, 'issuer') or contains($uri, 'authority') or contains($uri, 'rrc_moneyer') or contains($uri, 'ruler') or contains($uri, 'roman_emperor') or contains($uri,
				'artist') or contains($uri, 'engraver') or contains($uri, 'league')">
				<xsl:element name="org:Role" namespace="http://www.w3.org/ns/org#">
					<xsl:attribute name="rdf:about" select="@rdf:about"/>
					<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:when>
			<!-- make a hoard a find type -->
			<xsl:when test="$uri = 'http://nomisma.org/id/hoard'">
				<xsl:element name="nmo:FindType" namespace="http://nomisma.org/ontology#">
					<xsl:attribute name="rdf:about" select="@rdf:about"/>
					<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="nmo:{$element}" namespace="http://nomisma.org/ontology#">
					<xsl:attribute name="rdf:about" select="@rdf:about"/>
					<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- deprecate coin types -->
	<xsl:template match="nm:type_series_item">
		<xsl:variable name="uri" select="@rdf:about"/>
		<xsl:variable name="id" select="tokenize($uri, '/')[last()]"/>
		<nmo:TypeSeriesItem>
			<xsl:attribute name="rdf:about" select="$uri"/>
			<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>


			<xsl:choose>
				<xsl:when test="contains($uri, 'ric.') or contains($uri, 'rrc-')">
					<!-- deprecate RRC and RIC ids -->
					<skos:prefLabel xml:lang="en">
						<xsl:value-of select="skos:prefLabel"/>
					</skos:prefLabel>
					<dcterms:isReplacedBy>
						<xsl:attribute name="rdf:resource">
							<xsl:choose>
								<xsl:when test="contains($uri, 'ric.')">
									<xsl:value-of select="concat('http://numismatics.org/ocre/id/', $id)"/>
								</xsl:when>
								<xsl:when test="contains($uri, 'rrc-')">
									<xsl:value-of select="concat('http://numismatics.org/crro/id/', $id)"/>
								</xsl:when>
							</xsl:choose>
						</xsl:attribute>
					</dcterms:isReplacedBy>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</nmo:TypeSeriesItem>
	</xsl:template>

	<!-- deal with people -->
	<xsl:template match="nm:authority|nm:issuer|nm:rrc_moneyer|nm:ruler|nm:roman_emperor|nm:artist|nm:engraver|nm:league">
		<foaf:Person>
			<xsl:attribute name="rdf:about" select="@rdf:about"/>
			<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
			<xsl:apply-templates/>
			<org:hasMembership rdf:resource="{@rdf:about}#{local-name()}"/>
		</foaf:Person>
		<org:Membership rdf:about="{@rdf:about}#{local-name()}">
			<org:role rdf:resource="http://nomisma.org/id/{local-name()}"/>
		</org:Membership>
	</xsl:template>

	<xsl:template match="nm:hoard">
		<nmo:Hoard>
			<xsl:attribute name="rdf:about" select="@rdf:about"/>
			<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
			<xsl:apply-templates/>
			<xsl:if test="(nm:closing_date_start and nm:closing_date_end) or nm:closing_date">
				<nmo:hasClosingDate rdf:resource="{concat(@rdf:about, '#closingDate')}"/>				
			</xsl:if>
			<xsl:apply-templates select="nm:findspot/rdf:Description" mode="property"/>
		</nmo:Hoard>
		<xsl:apply-templates select="nm:findspot/rdf:Description" mode="class"/>
		<xsl:if test="(nm:closing_date_start and nm:closing_date_end) or nm:closing_date">
			<xsl:call-template name="closing-date">
				<xsl:with-param name="uri" select="@rdf:about"/>
				<xsl:with-param name="startDate" select="if (nm:closing_date_start) then nm:closing_date_start else nm:closing_date"/>
				<xsl:with-param name="endDate" select="if (nm:closing_date_end) then nm:closing_date_end else nm:closing_date"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- reprocess skos:related -->
	<xsl:template match="skos:related">
		<xsl:variable name="uri" select="@rdf:resource"/>

		<xsl:choose>
			<xsl:when test="contains($uri, 'pleiades')">
				<skos:relatedMatch rdf:resource="{$uri}"/>
			</xsl:when>
			<xsl:when test="contains($uri, 'wikipedia')">
				<xsl:variable name="pieces" select="tokenize($uri, '/')"/>
				<skos:exactMatch rdf:resource="http://dbpedia.org/resource/{$pieces[last()]}"/>
			</xsl:when>
			<!-- convert worldcat to source -->
			<xsl:when test="contains($uri, 'worldcat')">
				<dcterms:source rdf:resource="{$uri}"/>
			</xsl:when>
			<xsl:otherwise>
				<skos:exactMatch rdf:resource="{$uri}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- reprocess dcterms:isPartOf -->
	<xsl:template match="dcterms:isPartOf">
		<xsl:choose>
			<xsl:when test="parent::nm:type_series_item or parent::nm:hoard">
				<dcterms:source rdf:resource="{@rdf:resource}"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="rdf:Description" mode="property">
		<nmo:hasFindSpot>
			<xsl:attribute name="rdf:resource" select="if (@rdf:about) then @rdf:about else concat(ancestor::nm:hoard/@rdf:about, '#this')"/>
		</nmo:hasFindSpot>
	</xsl:template>

	<xsl:template match="rdf:Description" mode="class">
		<geo:SpatialThing rdf:about="{if (@rdf:about) then @rdf:about else concat(ancestor::nm:hoard/@rdf:about, '#this')}">
			<xsl:if test="descendant::geo:lat">
				<geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float">
					<xsl:value-of select="descendant::geo:lat"/>
				</geo:lat>
			</xsl:if>
			<xsl:if test="descendant::geo:long">
				<geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float">
					<xsl:value-of select="descendant::geo:long"/>
				</geo:long>
			</xsl:if>
			<xsl:if test="nm:uncertain_value">
				<un:hasUncertainty rdf:resource="http://nomisma.org/id/uncertain_value"/>
			</xsl:if>
		</geo:SpatialThing>
	</xsl:template>

	<xsl:template match="nm:material[parent::nm:denomination]">
		<nmo:hasMaterial rdf:resource="{@rdf:resource}"/>
	</xsl:template>

	<!-- ignore geo:lat, geo:long, nm:uncertain_value -->
	<xsl:template match="geo:long|geo:lat|nm:uncertain_value|nm:findspot|nm:mint[not(parent::rdf:RDF)]"/>

	<!-- handle closing dates -->
	<xsl:template name="closing-date">
		<xsl:param name="uri"/>
		<xsl:param name="startDate"/>
		<xsl:param name="endDate"/>
		
		<dcterms:PeriodOfTime rdf:about="{concat($uri, '#closingDate')}">
			<nmo:hasStartDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
				<xsl:value-of select="$startDate"/>
			</nmo:hasStartDate>
			<nmo:hasEndDate rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
				<xsl:value-of select="$endDate"/>
			</nmo:hasEndDate>				
		</dcterms:PeriodOfTime>
	</xsl:template>

	<!-- ignore closing date generic template -->
	<xsl:template match="nm:closing_date_start|nm:closing_date_end|nm:closing_date"/>
</xsl:stylesheet>
