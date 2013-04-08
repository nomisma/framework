<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:res="http://www.w3.org/2005/sparql-results#">
	<xsl:output method="html" indent="yes" encoding="UTF-8"/>
	
	<xsl:template match="/res:sparql">
		<html>
			<head>
				<title>SPARQLer Query Results</title>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/grids/grids-min.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/reset-fonts-grids/reset-fonts-grids.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/base/base-min.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/fonts/fonts-min.css"/>
			</head>
			<body class="yui-skin-sam">
				<div id="doc4">
					<div id="bd">
						<div style="width:100%; height:100%" id="map_canvas"/>
						<h1>SPARQLer Query Results</h1>
						<xsl:apply-templates select="//res:result"/>
					</div>
				</div>
				
			</body>
			
		</html>
		
		
	</xsl:template>
	
	<xsl:template match="res:result">
		<div style="width:33%;float:left;margin:20px 0;height:200px;">			
			<span>
				<a href="{res:binding[@name='uri']/res:uri}">
					<xsl:value-of select="res:binding[@name='uri']/res:uri"/>
				</a>
			</span>
			<br/>
			<span>
				<b>Publisher: </b>
				<xsl:value-of select="res:binding[@name='publisher']/res:literal"/>
			</span>
			<br/>
			<span>
				<b>Object Type: </b>
				<xsl:choose>
					<xsl:when test="contains(res:binding[@name='numismatic_term']/res:uri, 'coin')">coin</xsl:when>
					<!--<xsl:when test="contains(res:binding[@name='numismatic_term']/res:uri, 'hoard')">hoard</xsl:when>-->
					<xsl:otherwise>hoard</xsl:otherwise>
				</xsl:choose>
			</span>
			<br/>
			
			<xsl:if test="string(res:binding[@name='axis']/res:literal)">
				<span>
					<b>Axis: </b>
					<xsl:value-of select="res:binding[@name='axis']/res:literal"/>
				</span>
				<br/>
			</xsl:if>
			<xsl:if test="string(res:binding[@name='diameter']/res:literal)">
				<span>
					<b>Diameter: </b>
					<xsl:value-of select="res:binding[@name='axis']/res:diameter"/>
				</span>
				<br/>
			</xsl:if>
			<xsl:if test="string(res:binding[@name='weight']/res:literal)">
				<span>
					<b>Weight: </b>
					<xsl:value-of select="res:binding[@name='weight']/res:literal"/>
				</span>
				<br/>
			</xsl:if>
			<xsl:if test="string(res:binding[@name='findspot']/res:uri)">
				<span>
					<b>Findspot: </b>
					<a href="{res:binding[@name='findspot']/res:uri}">
						<xsl:value-of select="res:binding[@name='findspot']/res:uri"/>
					</a>
				</span>
				<br/>
			</xsl:if>
			<xsl:if test="(string(res:binding[@name='obvThumb']/res:uri) and string(res:binding[@name='revThumb']/res:uri)) or (string(res:binding[@name='obvRef']/res:uri) and string(res:binding[@name='revRef']/res:uri)) ">
				<xsl:choose>
					<xsl:when test="string(res:binding[@name='obvThumb']/res:uri) and string(res:binding[@name='revThumb']/res:uri)">
						<a href="{res:binding[@name='uri']/res:uri}">
							<img src="{res:binding[@name='obvThumb']/res:uri}" alt="obv" style="max-width:125px"/>
							<img src="{res:binding[@name='revThumb']/res:uri}" alt="rev" style="max-width:125px"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<a href="{res:binding[@name='uri']/res:uri}">
							<img src="{res:binding[@name='obvRef']/res:uri}" alt="obv" style="max-width:125px"/>
							<img src="{res:binding[@name='revRef']/res:uri}" alt="rev" style="max-width:125px"/>
						</a>
					</xsl:otherwise>
				</xsl:choose>				
				
			</xsl:if>
		</div>
	</xsl:template>
</xsl:stylesheet>