<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:nmo="http://nomisma.org/ontology#" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/"
	xmlns:org="http://www.w3.org/ns/org#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all" version="2.0">

	<!-- process any object except those which have been deprecated -->
	<xsl:template match="*[not(dcterms:isReplacedBy)]" mode="generateDoc">
		<doc>
			<xsl:variable name="id" select="substring-after(@rdf:about, 'id/')"/>
			<field name="id">
				<xsl:value-of select="$id"/>
			</field>
			<field name="uri">
				<xsl:value-of select="@rdf:about"/>
			</field>

			<!-- types -->
			<field name="type_uri">
				<xsl:value-of select="concat(namespace-uri(.), local-name())"/>
			</field>
			<field name="type">
				<xsl:value-of select="name()"/>
			</field>
			<xsl:for-each select="rdf:type">
				<xsl:variable name="uri" select="@rdf:resource"/>
				<field name="type">					
					<xsl:value-of
						select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
					/>
				</field>
				<field name="type_uri">
					<xsl:value-of select="$uri"/>
				</field>
			</xsl:for-each>

			<!-- roles for Persons/Organizations -->
			<xsl:apply-templates select="org:hasMembership"/>

			<!-- labels -->
			<field name="prefLabel">
				<xsl:value-of select="skos:prefLabel[@xml:lang='en']"/>
			</field>
			<xsl:for-each select="skos:prefLabel|skos:altLabel">
				<field name="label">
					<xsl:value-of select="."/>
				</field>
			</xsl:for-each>

			<!-- definition -->
			<field name="definition">
				<xsl:value-of select="skos:definition[@xml:lang='en']"/>
			</field>

			<!-- associated URIs -->
			<xsl:for-each select="skos:exactMatch|skos:relatedMatch">
				<field name="{local-name()}_uri">
					<xsl:value-of select="@rdf:resource"/>
				</field>
				<xsl:if test="contains(@rdf:resource, 'pleiades.stoa.org')">
					<field name="pleiades_uri">
						<xsl:value-of select="@rdf:resource"/>
					</field>
				</xsl:if>
			</xsl:for-each>

			<!-- geo -->
			<xsl:apply-templates select="geo:location"/>

			<field name="timestamp">
				<xsl:variable name="timestamp" select="string(current-dateTime())"/>
				<xsl:choose>
					<xsl:when test="contains($timestamp, 'Z')">
						<xsl:value-of select="$timestamp"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($timestamp, 'Z')"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
			<field name="text">
				<xsl:value-of select="$id"/>
				<xsl:text> </xsl:text>
				<xsl:for-each select="descendant-or-self::node()">
					<xsl:value-of select="text()"/>
					<xsl:text> </xsl:text>
					<xsl:if test="string(@resource)">
						<xsl:value-of select="@resource"/>
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</field>
		</doc>
	</xsl:template>

	<xsl:template match="geo:location">
		<xsl:variable name="uri" select="@rdf:resource"/>

		<xsl:apply-templates select="ancestor::rdf:RDF/geo:SpatialThing[@rdf:about=$uri]"/>
	</xsl:template>

	<xsl:template match="geo:SpatialThing">
		<xsl:choose>
			<xsl:when test="geo:lat and geo:long">
				<field name="geo">
					<xsl:value-of select="geo:long"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="geo:lat"/>
				</field>
			</xsl:when>
			<!--<xsl:when test="osgeo:asGeoJSON">
				<xsl:variable name="points" as="item()*">
					<xsl:analyze-string select="osgeo:asGeoJSON" regex="\[(-?\d+\.?\d+),(-?\d+\.?\d+)\]">
						<xsl:matching-substring>
							<xsl:value-of select="concat(regex-group(1), ' ', regex-group(2))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:variable>
				
				<field name="geo">
					<xsl:text>POLYGON((</xsl:text>
					<xsl:for-each select="$points[string-length(.) &gt; 0]">
						<xsl:value-of select="."/>
						<xsl:if test="not(position()=last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
					<xsl:text>))</xsl:text>
				</field>
			</xsl:when>-->
		</xsl:choose>
	</xsl:template>

	<xsl:template match="org:hasMembership">
		<xsl:variable name="uri" select="@rdf:resource"/>

		<xsl:apply-templates select="ancestor::rdf:RDF/org:Membership[@rdf:about=$uri]"/>
	</xsl:template>

	<xsl:template match="org:Membership">
		<xsl:variable name="uri" select="org:role/@rdf:resource"/>
		
		<field name="role_uri">
			<xsl:value-of select="$uri"/>
		</field>
		<field name="role_facet">
			<xsl:value-of select="$roles/role[@uri=$uri]"/>
		</field>
	</xsl:template>

</xsl:stylesheet>
