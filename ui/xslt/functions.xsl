<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nomisma="http://nomisma.org/" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">

	<!-- ***** FUNCTIONS ***** -->
	<!-- create a human readable date -->
	<xsl:function name="nomisma:normalizeDate">
		<xsl:param name="date"/>

		<xsl:if test="substring($date, 1, 1) != '-' and number(substring($date, 1, 4)) &lt; 500">
			<xsl:text>A.D. </xsl:text>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="$date castable as xs:date">
				<xsl:value-of select="format-date($date, '[D] [MNn] [Y]')"/>
			</xsl:when>
			<xsl:when test="$date castable as xs:gYearMonth">
				<xsl:variable name="normalized" select="xs:date(concat($date, '-01'))"/>
				<xsl:value-of select="format-date($normalized, '[MNn] [Y]')"/>
			</xsl:when>
			<xsl:when test="$date castable as xs:gYear or $date castable as xs:integer">
				<xsl:value-of select="abs(number($date))"/>
			</xsl:when>
		</xsl:choose>

		<xsl:if test="substring($date, 1, 1) = '-'">
			<xsl:text> B.C.</xsl:text>
		</xsl:if>
	</xsl:function>
	
	<!-- convert XSD compliant date datatypes into ISO 8601 dates (e.g., 1 B.C., "-0001"^^xsd:gYear = "0000" in ISO 8601) -->
	<xsl:function name="nomisma:xsdToIso">
		<xsl:param name="date"/>
			
		<xsl:variable name="year" select="if (substring($date, 1, 1) = '-') then substring($date, 1, 5) else substring($date, 1, 4)"/>
		<xsl:choose>
			<xsl:when test="number($year) &lt; 0">
				<!-- convert the year to ISO -->
				<xsl:value-of select="format-number(number($year) + 1, '0000')"/>
				<!-- include month and/or day when applicable -->
				<xsl:if test="string-length($date) &gt; 5">
					<xsl:value-of select="substring($date, 5)"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$date"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- parse the SPARQL query into a human-readable string -->
	<xsl:function name="nomisma:parseFilter">
		<xsl:param name="query"/>
		
		<xsl:variable name="pieces" select="tokenize(normalize-space($query), ';')"/>
		<xsl:for-each select="$pieces">
			<xsl:choose>
				<xsl:when test="contains(., '?prop')">
					<xsl:analyze-string select="." regex="\?prop\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:text>Authority/Issuer: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'portrait')">
					<xsl:analyze-string select="." regex="portrait\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:text>Portrait: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'deity')">
					<xsl:analyze-string select="." regex="deity\s&lt;(.*)&gt;">
						<xsl:matching-substring>
							<xsl:text>Deity: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="matches(normalize-space(.), '^from\s')">
					<xsl:analyze-string select="." regex="from\s(.*)">
						<xsl:matching-substring>
							<xsl:text>From Date: </xsl:text>
							<xsl:value-of select="nomisma:normalizeDate(regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="matches(normalize-space(.), '^to\s')">
					<xsl:analyze-string select="." regex="to\s(.*)">
						<xsl:matching-substring>
							<xsl:text>To Date: </xsl:text>
							<xsl:value-of select="nomisma:normalizeDate(regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:otherwise>
					<xsl:analyze-string select="." regex="nmo:has([A-Za-z]+)\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:value-of select="regex-group(1)"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(2))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not(position() = last())">
				<xsl:text> &amp; </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
	
	<xsl:function name="nomisma:getLabel">
		<xsl:param name="uri"/>
		
		<xsl:variable name="service" select="concat('http://localhost:8080/orbeon/nomisma/apis/getLabel?uri=', $uri)"/>
		
		<xsl:value-of select="document($service)/response"/>
	</xsl:function>
	
	<!-- ********************************** TEMPLATES ************************************ -->
	<xsl:template name="nomisma:evaluateDatatype">
		<xsl:param name="val"/>
		
		<xsl:choose>
			<!-- metadata fields must be a string -->
			<xsl:when test="ancestor::metadata or self::label">
				<xsl:value-of select="concat('&#x022;', replace($val, '&#x022;', '\\&#x022;'), '&#x022;')"/>
			</xsl:when>
			<xsl:when test="number($val)">
				<xsl:value-of select="$val"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('&#x022;', replace($val, '&#x022;', '\\&#x022;'), '&#x022;')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
