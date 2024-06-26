<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:nomisma="http://nomisma.org/" xmlns:saxon="http://saxon.sf.net/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:gvp="http://vocab.getty.edu/ontology#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:template match="/">
		<!-- construct an object that conforms to JSend JSON response format: https://github.com/omniti-labs/jsend -->
		<xsl:variable name="model" as="element()*">
			<_object>
				<type>FeatureCollection</type>
				<__context>https://raw.githubusercontent.com/LinkedPasts/linked-places/master/linkedplaces-context-v1.1.jsonld</__context>
				<features>
					<_array>
						<xsl:apply-templates select="descendant::res:result"/>
					</_array>
				</features>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="res:result">

		<_object>
			<__id>
				<xsl:value-of select="res:binding[@name = 'place']/res:uri"/>
			</__id>
			<type>Feature</type>
			<properties>
				<_object>
					<title>
						<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
					</title>
				</_object>
			</properties>
			<names>
				<_array>
					<_object>
						<toponym>
							<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
						</toponym>
						<lang>en</lang>
						<xsl:if test="res:binding[@name = 'source']">
							<citations>
								<_array>
									<_object>
										<label>
											<xsl:value-of
												select="res:binding[@name = 'sourceLabel']/res:literal"
											/>
										</label>
										<__id>
											<xsl:value-of
												select="res:binding[@name = 'source']/res:uri"/>
										</__id>
									</_object>
								</_array>
							</citations>
						</xsl:if>
					</_object>
				</_array>
			</names>

			<types>
				<_array>
					<_object>
						<xsl:choose>
							<xsl:when
								test="res:binding[@name = 'type']/res:uri = 'http://nomisma.org/ontology#Region'">
								<identifier>http://vocab.getty.edu/aat/300182722</identifier>
								<label>regions (geographic)</label>
								<sourceLabels>
									<_array>
										<_object>
											<label>regions (geographic)</label>
											<lang>en</lang>
										</_object>
									</_array>
								</sourceLabels>
							</xsl:when>
							<xsl:when
								test="res:binding[@name = 'type']/res:uri = 'http://nomisma.org/ontology#Mint'">
								<identifier>http://vocab.getty.edu/aat/300008347</identifier>
								<label>inhabited place</label>
								<sourceLabels>
									<_array>
										<_object>
											<label>inhabited place</label>
											<lang>en</lang>
										</_object>
									</_array>
								</sourceLabels>
							</xsl:when>
						</xsl:choose>
					</_object>
				</_array>
			</types>

			<xsl:if test="res:binding[@name = 'definition']">
				<descriptions>
					<_array>
						<_object>
							<value>
								<xsl:value-of
									select="normalize-space(res:binding[@name = 'definition']/res:literal)"
								/>
							</value>
							<lang>en</lang>
						</_object>
					</_array>
				</descriptions>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="res:binding[@name = 'lat'] and res:binding[@name = 'long']">
					<geometry>
						<_object>
							<type>Point</type>
							<coordinates>
								<_array>
									<_>
										<xsl:value-of
											select="res:binding[@name = 'long']/res:literal"/>
									</_>
									<_>
										<xsl:value-of
											select="res:binding[@name = 'lat']/res:literal"/>
									</_>
								</_array>
							</coordinates>
							<geowkt>
								<xsl:value-of
									select="concat('POINT(', res:binding[@name = 'long']/res:literal, ' ', res:binding[@name = 'lat']/res:literal, ')')"
								/>
							</geowkt>
						</_object>
					</geometry>
				</xsl:when>
				<xsl:when test="res:binding[@name = 'geojson']">
					<geometry datatype="json">
						<xsl:value-of select="res:binding[@name = 'geojson']/res:literal"/>
					</geometry>
				</xsl:when>
			</xsl:choose>

			<when>
				<_object>
					<xsl:if test="res:binding[@name = 'periods']">
						<periods>
							<_array>
								<xsl:for-each
									select="tokenize(res:binding[@name = 'periods']/res:literal, ' ')">

									<xsl:if test="contains(., 'vocab.getty.edu')">
										<xsl:variable name="uri" select="."/>

										<_object>
											<name>
												<!--<xsl:value-of select="doc('input:rdf')//gvp:Subject[@rdf:about = $uri]/skos:prefLabel[@xml:lang = 'en']"/>-->
											</name>
											<uri>
												<xsl:value-of select="."/>
											</uri>
										</_object>
									</xsl:if>
								</xsl:for-each>
							</_array>
						</periods>
					</xsl:if>
				</_object>
			</when>

			<!-- associated URIs -->
			<xsl:if
				test="res:binding[@name = 'closeMatches'] or res:binding[@name = 'exactMatches']">
				<links>
					<_array>
						<xsl:apply-templates
							select="res:binding[@name = 'closeMatches']/res:literal | res:binding[@name = 'exactMatches']/res:literal"
							mode="links"/>
					</_array>
				</links>
			</xsl:if>

			<xsl:if test="res:binding[@name = 'broaders']">
				<relations>
					<_array>
						<xsl:apply-templates select="res:binding[@name = 'broaders']"/>
					</_array>
				</relations>
			</xsl:if>

		</_object>
	</xsl:template>

	<xsl:template match="res:literal" mode="links">
		<xsl:variable name="type" select="replace(parent::node()/@name, 'Matches', 'Match')"/>

		<xsl:for-each select="tokenize(., ' ')">
			<_object>
				<type>
					<xsl:value-of select="$type"/>
				</type>
				<identifier>
					<xsl:value-of select="normalize-space(.)"/>
				</identifier>
			</_object>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="res:binding[@name = 'broaders']">
		<xsl:variable name="broaderLabels"
			select="tokenize(parent::node()/res:binding[@name = 'broaderLabels']/res:literal, ' ')"/>

		<xsl:for-each select="tokenize(res:literal, ' ')">
			<xsl:variable name="position" select="position()"/>
			<xsl:variable name="label" select="$broaderLabels[$position]"/>

			<_object>
				<relationType>gvp:broaderPartitive</relationType>
				<relationTo>
					<xsl:value-of select="."/>
				</relationTo>
				<label>
					<xsl:value-of select="$label"/>
				</label>
			</_object>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
