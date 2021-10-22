<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: October 2021
	Function: serialize SPARQL results for organization members into an HTML table 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name = 'id']/value"/>

	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="query" select="doc('input:query')"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/res:sparql"/>
	</xsl:template>

	<!-- HTML output -->
	<xsl:template match="res:sparql[count(descendant::res:result) &gt; 0]">
		<h3>
			<xsl:text>Associated Members </xsl:text>
			<small>
				<a href="#" class="toggle-button" id="toggle-listAgents" title="Click to hide or show the analysis form">
					<span class="glyphicon glyphicon-triangle-bottom"/>
				</a>
			</small>
		</h3>

		<div id="listAgents-div">
			<div style="margin-bottom:10px;" class="control-row">
				<a href="#" class="toggle-button btn btn-primary" id="toggle-listAgentsQuery"><span class="glyphicon glyphicon-plus"/> View SPARQL for full
					query</a>
				<a href="{$display_path}query?query={encode-for-uri(replace($query, '%ID%', $id))}&amp;output=csv" title="Download CSV" class="btn btn-primary"
					style="margin-left:10px">
					<span class="glyphicon glyphicon-download"/>Download CSV</a>
			</div>
			<div id="listAgentsQuery-div" style="display:none">
				<pre>
				<xsl:value-of select="replace($query, '%ID%', $id)"/>
			</pre>
			</div>

			<table class="table table-striped table-responsive">
				<thead>
					<tr>
						<th>
							<xsl:value-of select="nomisma:normalizeCurie('skos:prefLabel', 'en')"/>
						</th>
						<th>
							<xsl:value-of select="nomisma:normalizeCurie('org:role', 'en')"/>
						</th>
						<th>Date</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="descendant::res:result[not(res:binding[@name = 'uri']/res:uri = preceding-sibling::res:result/res:binding[@name = 'uri']/res:uri)]">
						<xsl:variable name="uri" select="res:binding[@name = 'uri']/res:uri"/>
						
						
						<tr>
							<td>
								<a href="{res:binding[@name = 'uri']/res:uri}">
									<xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
								</a>
							</td>
							<td>
								<a href="{res:binding[@name = 'role']/res:uri}">
									<xsl:value-of select="res:binding[@name = 'roleLabel']/res:literal"/>
								</a>
							</td>
							<td>
								<xsl:apply-templates select="//res:result[res:binding[@name = 'uri']/res:uri = $uri]" mode="render-date"/>
							</td>						
							
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</div>
	</xsl:template>

	<xsl:template match="res:result" mode="render-date">
		<xsl:value-of select="nomisma:normalizeYear(res:binding[@name = 'begin']/res:literal)"/>
		<xsl:if test="res:binding[@name = 'begin'] and res:binding[@name = 'end']">
			<xsl:text>–</xsl:text>
		</xsl:if>		
		<xsl:value-of select="nomisma:normalizeYear(res:binding[@name = 'end']/res:literal)"/>
		
		<xsl:if test="not(position() = last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
