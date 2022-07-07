<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:nomisma="http://nomisma.org/" xmlns:math="http://exslt.org/math" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- URL parameters -->
	<xsl:param name="api" select="tokenize(doc('input:request')/request/request-uri, '/')[last()]"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name = 'type']/value"/>
	<xsl:param name="dieStudy" select="doc('input:request')/request/parameters/parameter[name = 'dieStudy']/value"/>

	<!-- construct JSON response according to JSend format: https://github.com/omniti-labs/jsend -->
	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">
			<_object>
				<status>success</status>
				<data>
					<_object>
						<type>
							<xsl:value-of select="$type"/>
						</type>
						<dieStudy>
							<xsl:value-of select="$dieStudy"/>
						</dieStudy>
						<obverse>
							<xsl:call-template name="calculate">
								<xsl:with-param name="side">obverse</xsl:with-param>
								<xsl:with-param name="n" select="//res:sparql[1]//res:binding[@name = 'count']/res:literal" as="xs:integer"/>
								<xsl:with-param name="d" select="//res:sparql[2]//res:binding[@name = 'count']/res:literal" as="xs:integer"/>
								<xsl:with-param name="d1" select="//res:sparql[3]//res:binding[@name = 'dieCount']/res:literal" as="xs:integer"/>	
								<xsl:with-param name="f" as="element()*">
									<f>
										<xsl:copy-of select="//res:sparql[4]"/>
									</f>									
								</xsl:with-param>
							</xsl:call-template>
						</obverse>
						<reverse>
							
							<xsl:call-template name="calculate">
								<xsl:with-param name="side">reverse</xsl:with-param>
								<xsl:with-param name="n" select="//res:sparql[5]//res:binding[@name = 'count']/res:literal" as="xs:integer"/>
								<xsl:with-param name="d" select="//res:sparql[6]//res:binding[@name = 'count']/res:literal" as="xs:integer"/>
								<xsl:with-param name="d1" select="//res:sparql[7]//res:binding[@name = 'dieCount']/res:literal" as="xs:integer"/>
								<xsl:with-param name="f" as="element()*">
									<f>
										<xsl:copy-of select="//res:sparql[8]"/>
									</f>									
								</xsl:with-param>
							</xsl:call-template>
						</reverse>
						
					</_object>
				</data>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template name="calculate">
		<xsl:param name="side"/>
		<xsl:param name="n"/>
		<xsl:param name="d"/>
		<xsl:param name="d1"/>
		<xsl:param name="f"/>

		<_object>
			<n>
				<xsl:value-of select="$n"/>
			</n>
			<d>
				<xsl:value-of select="$d"/>
			</d>
			<d1>
				<xsl:value-of select="$d1"/>
			</d1>
			<xsl:if test="$n &gt; 0">				
				<!-- apply calculation based on API scheme -->
				<xsl:choose>
					<xsl:when test="$api = 'esty'">
						<xsl:call-template name="calculate_esty">
							<xsl:with-param name="n" select="$n" as="xs:integer"/>
							<xsl:with-param name="d" select="$d" as="xs:integer"/>
							<xsl:with-param name="d1" select="$d1" as="xs:integer"/>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>
				
				<xsl:apply-templates select="$f//res:sparql" mode="frequencies">
					<xsl:with-param name="side" select="$side"/>
				</xsl:apply-templates>
			</xsl:if>
		</_object>
	</xsl:template>

	<!-- render frequencies SPARQL query into JSON -->
	<xsl:template match="res:sparql" mode="frequencies">
		<xsl:param name="side"/>
		
		<frequencies>
			<_array>
				<xsl:apply-templates select="descendant::res:result" mode="frequencies">
					<xsl:with-param name="side" select="$side"/>
				</xsl:apply-templates>
			</_array>
		</frequencies>
	</xsl:template>

	<xsl:template match="res:result" mode="frequencies">
		<xsl:param name="side"/>
		
		<_object>
			<side>
				<xsl:value-of select="$side"/>
			</side>
			<frequency>
				<xsl:value-of select="res:binding[@name = 'frequency']/res:literal"/>
			</frequency>
			<dies>
				<xsl:value-of select="res:binding[@name = 'dieCount']/res:literal"/>
			</dies>
		</_object>
	</xsl:template>

	<!-- ***** CALCULATION TEMPLATES ***** -->
	<!-- Esty 2011, with p = 1 from addendum document -->
	<xsl:template name="calculate_esty">
		<xsl:param name="n"/>
		<xsl:param name="d"/>
		<xsl:param name="d1"/>

		<!-- Coverage (estimated) = 1 - ($d1 divided by $n), formula 1, Esty 2006 -->
		<xsl:variable name="c_est" select="1 - ($d1 div $n)"/>

		<!-- Total dies (estimated) = ($d divided by $c_est) * (1 + ($d1 divided by pd)), where p is 1 according to Esty 2011 -->
		<xsl:variable name="d_est" select="round(($d div $c_est) * (1 + ($d1 div $d)))"/>

		<!-- calculate the minimum and maximum confidence interval, formula 4 in Esty 2011 -->
		<xsl:variable name="d_min" select="$d_est - math:power((2 * $d_est) div $n, 2) - (((2 * $d_est) div $n) * math:sqrt(2 * $d_est))"/>
		<xsl:variable name="d_max" select="$d_est - math:power((2 * $d_est) div $n, 2) + (((2 * $d_est) div $n) * math:sqrt(2 * $d_est))"/>

		<c_est>
			<xsl:value-of select="$c_est"/>
		</c_est>
		<d_est>
			<xsl:value-of select="$d_est"/>
		</d_est>
		<d_min>
			<xsl:value-of select="round($d_min)"/>
		</d_min>
		<d_max>
			<xsl:value-of select="round($d_max)"/>
		</d_max>

	</xsl:template>

</xsl:stylesheet>
