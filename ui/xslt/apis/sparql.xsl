<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all">
	<xsl:include href="../sparql/templates.xsl"/>
	<!-- url params -->
	<xsl:param name="api" select="substring-after(doc('input:request')/request/request-url, 'apis/')"/>
	<xsl:param name="template">
		<xsl:choose>
			<xsl:when test="$api='avgAxis' or $api='avgDiameter' or $api='avgWeight'"
				>avgMeasurement</xsl:when>
			<xsl:when test="$api='getKml'">kml</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$api"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:template match="/">
		<xsl:choose>
			<!--<xsl:when test="$template = 'kml'">
				<xsl:call-template name="kml"/>
			</xsl:when>-->			
			<xsl:when test="$template = 'avgMeasurement'">
				<xsl:call-template name="avgMeasurement">
					<xsl:with-param name="measurement"
						select="lower-case(substring-after($api, 'avg'))"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$template = 'getLabel'">
				<xsl:call-template name="getLabel"/>
			</xsl:when>						
			<xsl:when test="$template = 'regionHierarchy'">
				<xsl:call-template name="regionHierarchy"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
