<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- config variable -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="service" select="concat($url, 'apis/reconcile')"/>

	<!-- request params -->
	<xsl:param name="suggest" select="
			if (contains(doc('input:request')/request/request-url, 'suggest/')) then
				true()
			else
				false()"/>

	<xsl:template match="/">
		<xsl:choose>
			<!-- generate default JSON service output -->
			<xsl:when test="//lst[@name = 'facet_fields']">
				<xsl:apply-templates select="//config"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$suggest = true()">
						<!-- apply alternative templates for the suggest API response instead of the default query response -->
						<xsl:variable name="model" as="element()*">
							<xsl:apply-templates select="descendant::result[@name = 'response']" mode="suggest"/>
						</xsl:variable>

						<xsl:apply-templates select="$model"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="model" as="element()*">
							<xsl:choose>
								<xsl:when test="count(descendant::response) &gt; 1">
									<_object>
										<xsl:apply-templates select="descendant::response">
											<xsl:sort order="ascending" select="lst[@name = 'responseHeader']/lst[@name = 'params']/str[@name = 'qid']"/>
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
				<preview>
					<_object>
						<url>
							<xsl:value-of select="concat($service, '/preview?id={{id}}')"/>
						</url>
						<height>90</height>
						<width>320</width>
					</_object>
				</preview>
				<suggest>
					<_object>
						<entity>
							<_object>
								<service_url>
									<xsl:value-of select="$service"/>
								</service_url>
								<service_path>/suggest/entity</service_path>
								<flyout_service_path>/flyout?id=${id}</flyout_service_path>
							</_object>
						</entity>
					</_object>
				</suggest>
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
			<xsl:when test="string(lst[@name = 'responseHeader']/lst[@name = 'params']/str[@name = 'qid'])">
				<xsl:element name="{descendant::str[@name = 'qid'][1]}">
					<xsl:apply-templates select="result[@name = 'response']" mode="query"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="result[@name = 'response']" mode="query"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- response for query results -->
	<xsl:template match="result[@name = 'response']" mode="query">
		<xsl:variable name="numFound" select="@numFound"/>
		<xsl:variable name="maxScore" select="@maxScore"/>

		<_object>
			<result>
				<_array>
					<xsl:apply-templates select="descendant::doc">
						<xsl:with-param name="mode">query</xsl:with-param>
						<xsl:with-param name="numFound" select="$numFound"/>
						<xsl:with-param name="maxScore" select="$maxScore"/>
					</xsl:apply-templates>
				</_array>
			</result>
		</_object>
	</xsl:template>

	<!-- response for suggest API -->
	<xsl:template match="result[@name = 'response']" mode="suggest">
		<_object>
			<code>/api/status/ok</code>
			<status>200 OK</status>
			<prefix>
				<xsl:value-of select="doc('input:request')/request/parameters/parameter[name = 'prefix']/value"/>
			</prefix>
			<result>
				<_array>
					<xsl:apply-templates select="descendant::doc">
						<xsl:with-param name="mode">suggest</xsl:with-param>
					</xsl:apply-templates>
				</_array>
			</result>
		</_object>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:param name="mode"/>
		<xsl:param name="numFound"/>
		<xsl:param name="maxScore"/>

		<_object>
			<id>
				<xsl:value-of select="str[@name = 'id']"/>
			</id>
			<name>
				<xsl:value-of select="str[@name = 'prefLabel']"/>
			</name>

			<xsl:choose>
				<xsl:when test="$mode = 'query'">
					<type>
						<_array>
							<xsl:apply-templates select="arr[@name = 'type']/str"/>
						</_array>
					</type>
				</xsl:when>
				<xsl:when test="$mode = 'suggest'">
					<n:type xmlns:n="//null">
						<xsl:apply-templates select="arr[@name = 'type']/str[not(. = 'skos:Concept')]"/>
					</n:type>
				</xsl:when>
			</xsl:choose>


			<xsl:if test="$mode = 'query'">
				<score>
					<xsl:value-of select="float[@name = 'score'] div $maxScore"/>
				</score>
				<match>
					<xsl:value-of
						select="
							if ($numFound = 1 and float[@name = 'score'] div $maxScore &gt; 0.8) then
								'true'
							else
								'false'"/>
				</match>
			</xsl:if>
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
