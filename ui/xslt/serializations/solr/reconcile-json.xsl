<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- config variable -->
	<xsl:variable name="url" select="/content/config/url"/>
	
	<!-- request params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name = 'q']/value"/>

	<xsl:template match="/">
		<xsl:choose>
			<!-- generate default JSON service output -->
			<xsl:when test="//lst[@name = 'facet_fields']">
				<xsl:apply-templates select="//config"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="model" as="element()*">
					<xsl:choose>
						<xsl:when test="count(descendant::response) &gt; 1">
							<_object>
								<xsl:apply-templates select="descendant::response">
									<xsl:sort order="ascending" select="lst[@name='responseHeader']/lst[@name = 'params']/str[@name = 'qid']"/>
								</xsl:apply-templates>
							</_object>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="descendant::response"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:apply-templates select="$model"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- TEMPLATES FOR DEFAULT RESPONSE -->
	<xsl:template match="config">
		<xsl:variable name="model" as="element()*">
			<_object>
				<name>
					<xsl:value-of select="title"/>
				</name>
				<view>
					<_object>
						<url>
							<xsl:value-of select="concat($url, 'id/{{id}}')"/>
						</url>
					</_object>
				</view>
				<identifierSpace>
					<xsl:value-of select="concat($url, 'id/')"/>
				</identifierSpace>
				<schemaSpace>http://nomisma.org/ontology</schemaSpace>
				<defaultTypes>
					<xsl:apply-templates select="/content/descendant::lst[@name = 'type']"/>
				</defaultTypes>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="lst[@name = 'type']">
		<_array>
			<xsl:apply-templates select="int[not(@name = 'nmo:TypeSeriesItem')]">
				<xsl:sort select="substring-after(@name, ':')" order="ascending"/>
			</xsl:apply-templates>
		</_array>
	</xsl:template>

	<xsl:template match="int">
		<_object>
			<id>
				<xsl:value-of select="@name"/>
			</id>
			<name>
				<xsl:value-of select="substring-after(@name, ':')"/>
			</name>
		</_object>
	</xsl:template>

	<!-- TEMPLATE FOR SEARCH RESPONSE -->
	<xsl:template match="response">
		<xsl:choose>
			<xsl:when test="string(lst[@name='responseHeader']/lst[@name = 'params']/str[@name = 'qid'])">
				<xsl:element name="{descendant::str[@name = 'qid'][1]}">
					<xsl:apply-templates select="result[@name='response']"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="result[@name='response']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="result[@name='response']">
		<xsl:variable name="numFound" select="@numFound"/>
		<xsl:variable name="maxScore" select="@maxScore"/>
		
		<_object>
			<result>
				<_array>
					<xsl:apply-templates select="descendant::doc">
						<xsl:with-param name="numFound" select="$numFound"/>
						<xsl:with-param name="maxScore" select="$maxScore"/>
					</xsl:apply-templates>
				</_array>
			</result>
		</_object>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:param name="numFound"/>
		<xsl:param name="maxScore"/>
		
		<_object>
			<id>
				<xsl:value-of select="str[@name = 'id']"/>
			</id>
			<name>
				<xsl:value-of select="str[@name = 'prefLabel']"/>
			</name>
			<type>
				<_array>
					<xsl:apply-templates select="arr[@name = 'type']/str"/>
				</_array>
			</type>
			<score>
				<xsl:value-of select="float[@name = 'score'] div $maxScore"/>
			</score>
			<match>
				<xsl:value-of select="
						if ($numFound = 1 and float[@name = 'score'] div $maxScore &gt; 0.8) then
							'true'
						else
							'false'"
				/>
			</match>
		</_object>
	</xsl:template>

	<xsl:template match="arr[@name = 'type']/str">
		<_object>
			<id>
				<xsl:value-of select="."/>
			</id>
			<name>
				<xsl:value-of select="substring-after(., ':')"/>
			</name>
		</_object>
	</xsl:template>

</xsl:stylesheet>
