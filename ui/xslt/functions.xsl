<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nomisma="http://nomisma.org/" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
	exclude-result-prefixes="#all">

	<!-- ***** FUNCTIONS ***** -->
	<!-- create a human readable date -->
	<xsl:function name="nomisma:normalizeDate">
		<xsl:param name="date"/>

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

		<xsl:choose>
			<xsl:when test="substring($date, 1, 1) = '-'">
				<xsl:text> BCE</xsl:text>
			</xsl:when>
			<xsl:when test="substring($date, 1, 1) != '-' and number(substring($date, 1, 4)) &lt; 500">
				<xsl:text> CE</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:function>

	<!-- convert XSD compliant date datatypes into ISO 8601 dates (e.g., 1 B.C., "-0001"^^xsd:gYear = "0000" in ISO 8601) -->
	<xsl:function name="nomisma:xsdToIso">
		<xsl:param name="date"/>

		<xsl:variable name="year" select="
				if (substring($date, 1, 1) = '-') then
					substring($date, 1, 5)
				else
					substring($date, 1, 4)"/>
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
					<xsl:choose>
						<xsl:when test="matches(., 'https?://')">
							<xsl:analyze-string select="." regex="deity\s&lt;(.*)&gt;">
								<xsl:matching-substring>
									<xsl:text>Deity: </xsl:text>
									<xsl:value-of select="nomisma:getLabel(regex-group(1))"/>
								</xsl:matching-substring>
							</xsl:analyze-string>
						</xsl:when>
						<xsl:when test="matches(., 'deity\snm:')">
							<xsl:analyze-string select="." regex="deity\s(nm:.*)">
								<xsl:matching-substring>
									<xsl:text>Authority: </xsl:text>
									<xsl:value-of select="nomisma:getLabel(regex-group(1))"/>
								</xsl:matching-substring>
							</xsl:analyze-string>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains(., 'authPerson')">
					<xsl:analyze-string select="." regex="authPerson\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:text>Authority: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'authCorp')">
					<xsl:analyze-string select="." regex="authCorp\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:text>State: </xsl:text>
							<xsl:value-of select="nomisma:getLabel(regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:when test="contains(., 'dynasty')">
					<xsl:analyze-string select="." regex="dynasty\s(nm:.*)">
						<xsl:matching-substring>
							<xsl:text>Dynasty: </xsl:text>
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

	<!-- ***** Functions for linked.art JSON-LD serialization ***** -->
	<xsl:function name="nomisma:expandDate">
		<xsl:param name="date"/>
		<xsl:param name="range"/>


		<!-- the data should be assumed to be XSD 1.0 compliant, which means that in order to make BC dates compliant to ISO 8601/XSD 1.1, 
			a year should be added mathematically so that 1 BC is "0000" in the JSON output -->
		<xsl:choose>
			<xsl:when test="substring($date, 1, 1) = '-'">

				<xsl:variable name="pieces" select="tokenize(substring($date, 2), '-')"/>
				<xsl:variable name="new-year" select="format-number((number($pieces[1]) * -1) + 1, '0000')"/>

				<xsl:value-of select="$new-year"/>
				<xsl:if test="string($pieces[2])">
					<xsl:value-of select="concat('-', $pieces[2])"/>
				</xsl:if>
				<xsl:if test="string($pieces[3])">
					<xsl:value-of select="concat('-', $pieces[3])"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$date"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="nomisma:normalizeYear">
		<xsl:param name="year"/>

		<xsl:choose>
			<xsl:when test="number($year) &lt;= 0">
				<xsl:value-of select="abs(number($year))"/>
				<xsl:text> BCE</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="number($year)"/>
				<xsl:if test="number($year) &lt;= 400">
					<xsl:text> CE</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- turn rdf properties into human-readable labels. If a label for a particular label is not translated, the function will re-run in English -->
	<xsl:function name="nomisma:normalizeCurie">
		<xsl:param name="curie"/>
		<xsl:param name="lang"/>

		<xsl:choose>
			<xsl:when test="$lang = 'fr'">
				<xsl:choose>

					<!-- properties -->
					<xsl:when test="$curie = 'kon:hasShape'">Forme</xsl:when>

					<xsl:otherwise>
						<xsl:value-of select="nomisma:normalizeCurie($curie, 'en')"/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<!-- classes -->
					<xsl:when test="$curie = 'crm:E52_Time-Span'">Time Span</xsl:when>
					<xsl:when test="$curie = 'crm:E4_Period'">Period</xsl:when>
					<xsl:when test="$curie = 'crm:E28_Symbolic_Object'">Die</xsl:when>
					<xsl:when test="$curie = 'crm:E37_Mark'">Symbol</xsl:when>
					<xsl:when test="$curie = 'nmo:Authenticity'">Authenticity</xsl:when>
					<xsl:when test="$curie = 'nmo:CoinWear'">Coin Wear</xsl:when>
					<xsl:when test="$curie = 'nmo:Deposition Type'">Deposition Type</xsl:when>
					<xsl:when test="$curie = 'nmo:FieldOfNumismatics'">Field of Numismatics</xsl:when>
					<xsl:when test="$curie = 'nmo:FindType'">Find Type</xsl:when>					
					<xsl:when test="$curie = 'nmo:Monogram'">Monogram</xsl:when>
					<xsl:when test="$curie = 'nmo:NumismaticObject'">Numismatic Object</xsl:when>
					<xsl:when test="$curie = 'nmo:NumismaticTerm'">Numismatic Term</xsl:when>					
					<xsl:when test="$curie = 'nmo:ObjectType'">Object Type</xsl:when>
					<xsl:when test="$curie = 'nmo:PeculiarityOfProduction'">Peculiarity of Production</xsl:when>
					<xsl:when test="$curie = 'nmo:ReferenceWork'">Reference Work</xsl:when>
					<xsl:when test="$curie = 'nmo:SecondaryTreatment'">Secondary Treatment</xsl:when>
					<xsl:when test="$curie = 'nmo:TypeSeries'">Type Series</xsl:when>
					<xsl:when test="$curie = 'nmo:TypeSeriesItem'">Coin Type</xsl:when>
					

					<!-- properties -->
					<xsl:when test="$curie = 'crm:P4_has_time-span'">Time Span</xsl:when>
					<xsl:when test="$curie = 'crm:P7_took_place_at'">Production Place</xsl:when>
					<xsl:when test="$curie = 'crm:P10_falls_within'">Period</xsl:when>
					<xsl:when test="$curie = 'crm:P14_carried_out_by'">Artist</xsl:when>
					<xsl:when test="$curie = 'crm:P32_used_general_technique'">Technique</xsl:when>
					<xsl:when test="$curie = 'crm:P45_consists_of'">Material</xsl:when>
					<xsl:when test="$curie = 'crm:P50_has_current_keeper'">Current Keeper</xsl:when>
					<xsl:when test="$curie = 'crm:P106_is_composed_of'">Constituent Letters</xsl:when>
					<xsl:when test="$curie = 'geo:lat'">Latitude</xsl:when>
					<xsl:when test="$curie = 'geo:long'">Longitude</xsl:when>
					<xsl:when test="$curie = 'dcterms:isPartOf'">Part Of</xsl:when>
					<xsl:when test="$curie = 'dcterms:source'">Reference</xsl:when>
					<xsl:when test="$curie = 'nmo:hasStartDate'">Start Date</xsl:when>
					<xsl:when test="$curie = 'nmo:hasEndDate'">End Date</xsl:when>
					<xsl:when test="$curie = 'org:role'">Role</xsl:when>
					<xsl:when test="$curie = 'org:organization'">Organization</xsl:when>
					<xsl:when test="$curie = 'osgeo:asGeoJSON'">GeoJSON</xsl:when>
					<xsl:when test="$curie = 'skos:prefLabel'">Preferred Label</xsl:when>
					<xsl:when test="$curie = 'skos:altLabel'">Alternate Label</xsl:when>
					<xsl:when test="$curie = 'skos:broader'">Broader Concept</xsl:when>
					<xsl:when test="$curie = 'skos:changeNote'">Change Note</xsl:when>
					<xsl:when test="$curie = 'skos:closeMatch'">Close Match</xsl:when>
					<xsl:when test="$curie = 'skos:exactMatch'">Exact Match</xsl:when>
					<xsl:when test="$curie = 'skos:inScheme'">Concept Scheme</xsl:when>
					<xsl:when test="$curie = 'skos:related'">Related Entity</xsl:when>

					<xsl:otherwise>
						<xsl:variable name="localName" select="substring-after($curie, ':')"/>

						<xsl:value-of select="concat(upper-case(substring($localName, 1, 1)), substring($localName, 2))"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- ********************************** TEMPLATES ************************************ -->
	<xsl:template name="nomisma:evaluateDatatype">
		<xsl:param name="val"/>

		<xsl:choose>
			<!-- metadata fields must be a string -->
			<xsl:when test="ancestor::metadata">
				<xsl:value-of select="concat('&#x022;', replace($val, '&#x022;', '\\&#x022;'), '&#x022;')"/>
			</xsl:when>		
			
			<xsl:when test="number($val) or $val = '0'">
				<xsl:choose>					
					<xsl:when test="@datatype = 'xs:string'">
						<xsl:value-of select="concat('&#x022;', replace($val, '&#x022;', '\\&#x022;'), '&#x022;')"/>
					</xsl:when>					
					<xsl:when test="@datatype = 'xs:integer'">
						<xsl:value-of select="$val"/>
					</xsl:when>
					<xsl:when test="@datatype = 'xs:gYear'">
						<xsl:value-of select="concat('&#x022;', replace($val, '&#x022;', '\\&#x022;'), '&#x022;')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$val"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@datatype = 'json'">
				<xsl:value-of select="$val"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('&#x022;', replace($val, '&#x022;', '\\&#x022;'), '&#x022;')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
