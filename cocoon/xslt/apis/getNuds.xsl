<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:nm="http://nomisma.org/id/" exclude-result-prefixes="xhtml xsl xs nm rdf rdfa skos" version="2.0">

	<xsl:param name="id-path"/>
	<xsl:param name="identifiers"/>
	<xsl:param name="lang"/>

	<xsl:variable name="content" as="element()*">
		<content xmlns="http://www.w3.org/1999/xhtml">
			<xsl:for-each select="tokenize($identifiers, '\|')">
				<xsl:if test="doc-available(concat($id-path, '/', ., '.txt'))">
					<xsl:copy-of select="document(concat($id-path, '/', ., '.txt'))/*"/>
				</xsl:if>
			</xsl:for-each>
		</content>
	</xsl:variable>

	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
			<xsl:variable name="id-param">
				<xsl:text>struck|</xsl:text>
				<xsl:for-each select="distinct-values($content/descendant::*/@resource)">
					<xsl:value-of select="."/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url" select="concat('cocoon:/apis/getRdf?identifiers=', $id-param)"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="count($content/xhtml:div) = 1">
				<xsl:apply-templates select="$content/xhtml:div"/>
			</xsl:when>
			<xsl:when test="count($content/xhtml:div) &gt; 1">
				<nudsGroup xmlns="http://nomisma.org/nuds" xmlns:xlink="http://www.w3.org/1999/xlink">
					<xsl:apply-templates select="$content/xhtml:div"/>
				</nudsGroup>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!--***************************************** Process Nomisma Coin Type XHTML+RDFa into NUDS **************************************** -->
	<xsl:template match="xhtml:div[@typeof='type_series_item']">
		<nuds xmlns="http://nomisma.org/nuds" xmlns:xlink="http://www.w3.org/1999/xlink">
			<nudsHeader>
				<nudsid>
					<xsl:value-of select="@about"/>
				</nudsid>
			</nudsHeader>
			<descMeta>
				<!-- title -->
				<xsl:choose>
					<xsl:when test="xhtml:div[@property='skos:prefLabel'][@xml:lang=$lang]">
						<title xml:lang="{$lang}">
							<xsl:value-of select="xhtml:div[@property='skos:prefLabel'][@xml:lang=$lang]"/>
						</title>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="xhtml:div[@property='skos:prefLabel'][@xml:lang='en']">
								<title xml:lang="en">
									<xsl:value-of select="xhtml:div[@property='skos:prefLabel'][@xml:lang='en']"/>
								</title>
							</xsl:when>
							<xsl:otherwise>
								<title>
									<xsl:value-of select="xhtml:div[@property='skos:prefLabel'][1]"/>
								</title>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<typeDesc xlink:type="simple" xlink:href="http://nomisma.org/id/{@about}">
					<xsl:for-each select="xhtml:div[@property='dcterms:format']">
						<xsl:call-template name="generate_element">
							<xsl:with-param name="element">objectType</xsl:with-param>
							<xsl:with-param name="role"/>
							<xsl:with-param name="uri" select="if (string(@resource)) then concat('http://nomisma.org/id/', @resource) else ''"/>
						</xsl:call-template>
					</xsl:for-each>
					<!-- manufacture-->
					<manufacture xlink:type="simple" xlink:href="http://nomisma.org/id/struck">
						<xsl:choose>
							<xsl:when test="string($rdf/*[@rdf:about = 'http://nomisma.org/id/struck']/skos:prefLabel[@xml:lang=$lang][1])">
								<xsl:value-of select="$rdf/*[@rdf:about = 'http://nomisma.org/id/struck']/skos:prefLabel[@xml:lang=$lang][1]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$rdf/*[@rdf:about = 'http://nomisma.org/id/struck']/skos:prefLabel[@xml:lang='en'][1]"/>
							</xsl:otherwise>
						</xsl:choose>
					</manufacture>


					<xsl:if test="xhtml:div[@property='start_date'] or xhtml:div[@property='end_date']">
						<xsl:call-template name="date">
							<xsl:with-param name="fromDate" select="xhtml:div[@property='start_date']/@content"/>
							<xsl:with-param name="toDate" select="xhtml:div[@property='end_date']/@content"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:for-each select="xhtml:div[@property='denomination']">
						<xsl:call-template name="generate_element">
							<xsl:with-param name="element">denomination</xsl:with-param>
							<xsl:with-param name="role"/>
							<xsl:with-param name="uri" select="if (string(@resource)) then concat('http://nomisma.org/id/', @resource) else ''"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:for-each select="xhtml:div[@property='material']">
						<xsl:call-template name="generate_element">
							<xsl:with-param name="element">material</xsl:with-param>
							<xsl:with-param name="role"/>
							<xsl:with-param name="uri" select="if (string(@resource)) then concat('http://nomisma.org/id/', @resource) else ''"/>
						</xsl:call-template>
					</xsl:for-each>

					<!-- authority -->
					<xsl:if test="xhtml:div[@property='authority'] or xhtml:div[@property='issuer']">
						<authority>
							<xsl:for-each select="xhtml:div[@property='authority']">
								<xsl:call-template name="generate_element">
									<xsl:with-param name="element">persname</xsl:with-param>
									<xsl:with-param name="role">authority</xsl:with-param>
									<xsl:with-param name="uri" select="if (string(@resource)) then concat('http://nomisma.org/id/', @resource) else ''"/>
								</xsl:call-template>
							</xsl:for-each>
							<xsl:for-each select="xhtml:div[@property='issuer']">
								<xsl:call-template name="generate_element">
									<xsl:with-param name="element">persname</xsl:with-param>
									<xsl:with-param name="role">issuer</xsl:with-param>
									<xsl:with-param name="uri" select="if (string(@resource)) then concat('http://nomisma.org/id/', @resource) else ''"/>
								</xsl:call-template>
							</xsl:for-each>
						</authority>
					</xsl:if>

					<!-- geographic -->
					<xsl:if test="xhtml:div[@property='mint']">
						<geographic>
							<xsl:for-each select="xhtml:div[@property='mint']">
								<xsl:call-template name="generate_element">
									<xsl:with-param name="element">geogname</xsl:with-param>
									<xsl:with-param name="role">mint</xsl:with-param>
									<xsl:with-param name="uri" select="if (string(@resource)) then concat('http://nomisma.org/id/', @resource) else ''"/>
								</xsl:call-template>
							</xsl:for-each>
						</geographic>
					</xsl:if>

					<!-- obverse -->
					<xsl:apply-templates select="xhtml:div[@rel='obverse']"/>
					<xsl:apply-templates select="xhtml:div[@rel='reverse']"/>
				</typeDesc>
			</descMeta>
		</nuds>
	</xsl:template>

	<xsl:template match="xhtml:div[@rel='obverse']|xhtml:div[@rel='reverse']">
		<xsl:element name="{@rel}" namespace="http://nomisma.org/nuds">
			<xsl:if test="xhtml:div[@property='legend']">
				<xsl:element name="legend" namespace="http://nomisma.org/nuds">
					<xsl:value-of select="xhtml:div[@property='legend']"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="xhtml:div[@property='description']">
				<xsl:element name="type" namespace="http://nomisma.org/nuds">
					<xsl:element name="description" namespace="http://nomisma.org/nuds">
						<xsl:attribute name="xml:lang">en</xsl:attribute>
						<xsl:value-of select="xhtml:div[@property='description']"/>
					</xsl:element>
				</xsl:element>				
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<xsl:template name="generate_element">
		<xsl:param name="element"/>
		<xsl:param name="role"/>
		<xsl:param name="uri"/>

		<xsl:element name="{$element}" namespace="http://nomisma.org/nuds">
			<xsl:attribute name="xlink:type">simple</xsl:attribute>
			<xsl:if test="string($role)">
				<xsl:attribute name="xlink:role" select="$role"/>
			</xsl:if>
			<xsl:if test="ancestor::xhtml:div[@rel='uncertain_value']">
				<xsl:attribute name="certainty">uncertain</xsl:attribute>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="string($uri)">
					<xsl:attribute name="xlink:href" select="$uri"/>
					<!-- get the prefLabel from nomisma only when there isn't a value already -->
					<xsl:choose>
						<xsl:when test="string(normalize-space(.))">
							<xsl:value-of select="."/>
						</xsl:when>
						<xsl:otherwise>
							<!-- get the English prefLabel by default.  If there is no @xml:lang defined, just get first prefLabel -->
							<xsl:choose>
								<xsl:when test="string($rdf/*[@rdf:about = $uri]/skos:prefLabel[@xml:lang=$lang][1])">
									<xsl:value-of select="$rdf/*[@rdf:about = $uri]/skos:prefLabel[@xml:lang=$lang][1]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$rdf/*[@rdf:about = $uri]/skos:prefLabel[@xml:lang='en'][1]"/>
								</xsl:otherwise>
							</xsl:choose>

						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template name="date" xmlns="http://nomisma.org/nuds">
		<xsl:param name="fromDate"/>
		<xsl:param name="toDate"/>

		<xsl:choose>
			<xsl:when test="number($fromDate) = number($toDate)">
				<date>
					<xsl:attribute name="standardDate">
						<xsl:value-of select="format-number(number($fromDate), '0000')"/>
					</xsl:attribute>
					<xsl:value-of select="nm:normalize_date($fromDate)"/>
				</date>
			</xsl:when>
			<xsl:otherwise>
				<dateRange>
					<fromDate>
						<xsl:attribute name="standardDate">
							<xsl:value-of select="format-number(number($fromDate), '0000')"/>
						</xsl:attribute>
						<xsl:value-of select="nm:normalize_date($fromDate)"/>
					</fromDate>
					<toDate>
						<xsl:attribute name="standardDate">
							<xsl:value-of select="format-number(number($toDate), '0000')"/>
						</xsl:attribute>
						<xsl:value-of select="nm:normalize_date($toDate)"/>
					</toDate>
				</dateRange>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:function name="nm:normalize_date">
		<xsl:param name="year"/>
		<xsl:if test="number($year) &lt; 500 and number($year) &gt; 0">
			<xsl:text>A.D. </xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="number($year) &lt;= 0">
				<xsl:value-of select="abs(number($year)) + 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="abs(number($year))"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="number($year) &lt; 0">
			<xsl:text> B.C.</xsl:text>
		</xsl:if>
	</xsl:function>
</xsl:stylesheet>
