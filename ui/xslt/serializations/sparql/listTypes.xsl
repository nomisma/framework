<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"  xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:include href="../../functions.xsl"/>
	
	<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>

	<xsl:variable name="display_path">../</xsl:variable>

	<xsl:variable name="classes" as="item()*">
		<classes>
			<class map="false" types="false">nmo:Collection</class>
			<class map="true" types="true" prop="nmo:hasDenomination">nmo:Denomination</class>
			<class map="true" types="true" prop="?prop">rdac:Family</class>
			<class map="true" types="false">nmo:Ethnic</class>
			<class map="false" types="false">nmo:FieldOfNumismatics</class>
			<class map="true" types="false">nmo:Hoard</class>
			<class map="true" types="true" prop="nmo:hasManufacture">nmo:Manufacture</class>
			<class map="true" types="true" prop="nmo:hasMaterial">nmo:Material</class>
			<class map="true" types="true" prop="nmo:hasMint">nmo:Mint</class>
			<class map="false" types="false">nmo:NumismaticTerm</class>
			<class map="true" types="false">nmo:ObjectType</class>
			<class map="true" types="true" prop="?prop">foaf:Group</class>
			<class map="true" types="true" prop="?prop">foaf:Organization</class>			
			<class map="true" types="true" prop="?prop">foaf:Person</class>
			<class map="false" types="false">crm:E4_Period</class>
			<class>nmo:ReferenceWork</class>
			<class map="true" types="true" prop="nmo:hasRegion">nmo:Region</class>
			<class map="false" types="false">org:Role</class>
			<class map="false" types="false">nmo:TypeSeries</class>
			<class map="false" types="false">un:Uncertainty</class>
			<class map="false" types="false">nmo:CoinWear</class>
		</classes>
	</xsl:variable>

	<xsl:variable name="listTypes-query"><![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX nm:	<http://nomisma.org/id/>
PREFIX nmo:	<http://nomisma.org/ontology#>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT * WHERE {
 ?type PROP nm:ID ;
   a nmo:TypeSeriesItem ;
   skos:prefLabel ?label FILTER(langMatches(lang(?label), "en")) .
   MINUS {?type dcterms:isReplacedBy ?replaced}
   ?type dcterms:source ?source . 
   	?source skos:prefLabel ?sourceLabel FILTER(langMatches(lang(?sourceLabel), "en"))
   OPTIONAL {?type nmo:hasStartDate ?startDate}
   OPTIONAL {?type nmo:hasEndDate ?endDate}
   OPTIONAL {?type nmo:hasMint ?mint . 
   	?mint skos:prefLabel ?mintLabel FILTER(langMatches(lang(?mintLabel), "en"))}
   OPTIONAL {?type nmo:hasDenomination ?den . 
   	?den skos:prefLabel ?denLabel FILTER(langMatches(lang(?denLabel), "en"))}
}]]></xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/res:sparql"/>
	</xsl:template>

	<xsl:template match="res:sparql[count(descendant::res:result) &gt; 0]">		
		<!-- aggregate ids and get URI space -->
		<xsl:variable name="type_series_items" as="element()*">
			<type_series_items>
				<xsl:for-each select="descendant::res:result/res:binding[@name='type']/res:uri">
					<item>
						<xsl:value-of select="."/>
					</item>
				</xsl:for-each>
			</type_series_items>
		</xsl:variable>
		
		<xsl:variable name="type_series" as="element()*">
			<list>
				<xsl:for-each select="distinct-values(descendant::res:result/res:binding[@name='type']/substring-before(res:uri, 'id/'))">
					<xsl:variable name="uri" select="."/>
					<type_series uri="{$uri}">
						<xsl:for-each select="$type_series_items//item[starts-with(., $uri)]">
							<item>
								<xsl:value-of select="substring-after(., 'id/')"/>
							</item>
						</xsl:for-each>
					</type_series>
				</xsl:for-each>
			</list>
		</xsl:variable>
		
		<!-- use the Numishare Results API to display example coins -->
		<xsl:variable name="sparqlResult" as="element()*">
			<response>
				<xsl:for-each select="$type_series//type_series">
					<xsl:variable name="baseUri" select="concat(@uri, 'id/')"/>
					<xsl:variable name="ids" select="string-join(item, '|')"/>
					
					<xsl:variable name="service" select="concat('http://localhost:8080/orbeon/nomisma/apis/numishareResults?identifiers=', encode-for-uri($ids), '&amp;baseUri=',
						encode-for-uri($baseUri))"/>
					<xsl:copy-of select="document($service)/response/*"/>
				</xsl:for-each>
			</response>
		</xsl:variable>
		
		<xsl:variable name="prop" select="$classes//class[text()=$type]/@prop"/>
		<xsl:variable name="query" select="replace(replace($listTypes-query, 'ID', $id), 'PROP', $prop)"/>
		
		<!-- HTML output -->
		<h3>Associated Types <small>(max 10)</small></h3>		
		<div style="margin-bottom:10px;" class="control-row">
			<a href="#" class="toggle-button btn btn-primary" id="toggle-listTypes"><span class="glyphicon glyphicon-plus"/> View SPARQL for full query</a>
			<a href="{$display_path}query?query={encode-for-uri($query)}&amp;output=csv" title="Download CSV" class="btn btn-primary" style="margin-left:10px">
				<span class="glyphicon glyphicon-download"/>Download CSV</a>
		</div>
		<div id="listTypes-div" style="display:none">
			<pre>
				<xsl:value-of select="$query"/>
			</pre>
		</div>
		
		<table class="table table-striped">
			<thead>
				<tr>
					<th>Type</th>
					<th>Type Series</th>
					<xsl:if test="$type='foaf:Person' or $type='foaf:Organization' or $type='rdac:Family'">
						<th>Role</th>
					</xsl:if>
					<th style="width:280px">Example</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="descendant::res:result">
					<xsl:variable name="type_id" select="substring-after(res:binding[@name='type']/res:uri, 'id/')"/>
					
					<tr>
						<td>
							<a href="{res:binding[@name='type']/res:uri}">
								<xsl:value-of select="res:binding[@name='label']/res:literal"/>
							</a>
							<dl class="dl-horizontal">
								<xsl:if test="res:binding[@name='mint']/res:uri">
									<dt>Mint</dt>
									<dd>
										<a href="{res:binding[@name='mint']/res:uri}">
											<xsl:value-of select="res:binding[@name='mintLabel']/res:literal"/>
										</a>
									</dd>
								</xsl:if>
								<xsl:if test="res:binding[@name='den']/res:uri">
									<dt>Denomination</dt>
									<dd>
										<a href="{res:binding[@name='den']/res:uri}">
											<xsl:value-of select="res:binding[@name='denLabel']/res:literal"/>
										</a>
									</dd>
								</xsl:if>
								<xsl:if test="res:binding[@name='startDate']/res:literal or res:binding[@name='endDate']/res:literal">
									<dt>Date</dt>
									<dd>
										<xsl:value-of select="nomisma:normalizeDate(res:binding[@name='startDate']/res:literal)"/>
										<xsl:if test="res:binding[@name='startDate']/res:literal and res:binding[@name='startDate']/res:literal"> - </xsl:if>
										<xsl:value-of select="nomisma:normalizeDate(res:binding[@name='endDate']/res:literal)"/>
									</dd>
								</xsl:if>
							</dl>
						</td>
						<td>
							<a href="{res:binding[@name='source']/res:uri}">
								<xsl:value-of select="res:binding[@name='sourceLabel']/res:literal"/>
							</a>
						</td>
						<xsl:if test="$type = 'foaf:Group' or $type='foaf:Person' or $type='foaf:Organization' or $type='rdac:Family'">
							<td>
								<xsl:variable name="uri" select="res:binding[@name='prop']/res:uri"/>
								<a href="{$uri}">
									<!--<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>-->
									<xsl:value-of select="$uri"/>
								</a>
								
							</td>
						</xsl:if>
						<td class="text-right">
							<xsl:apply-templates select="$sparqlResult//group[@id=$type_id]/descendant::object" mode="results"/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="object" mode="results">
		<xsl:variable name="position" select="position()"/>
		<!-- obverse -->
		<xsl:choose>
			<xsl:when test="string(obvRef) and string(obvThumb)">
				<a class="thumbImage" rel="gallery" href="{obvRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{obvThumb}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(obvRef)) and string(obvThumb)">
				<img src="{obvThumb}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(obvRef) and not(string(obvThumb))">
				<a class="thumbImage" rel="gallery" href="{obvRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{obvRef}" style="max-width:120px"/>
				</a>
			</xsl:when>
		</xsl:choose>
		<!-- reverse-->
		<xsl:choose>
			<xsl:when test="string(revRef) and string(revThumb)">
				<a class="thumbImage" rel="gallery" href="{revRef}" title="Reverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{revThumb}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(revRef)) and string(revThumb)">
				<img src="{revThumb}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(revRef) and not(string(revThumb))">
				<a class="thumbImage" rel="gallery" href="{revRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{revRef}" style="max-width:120px"/>
				</a>
			</xsl:when>
		</xsl:choose>
		<!-- combined -->
		<xsl:choose>
			<xsl:when test="string(comRef) and string(comThumb)">
				<a class="thumbImage" rel="gallery" href="{comRef}" title="Reverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{comThumb}"/>
				</a>
			</xsl:when>
			<xsl:when test="not(string(comRef)) and string(comThumb)">
				<img src="{comThumb}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
				</img>
			</xsl:when>
			<xsl:when test="string(comRef) and not(string(comThumb))">
				<a class="thumbImage" rel="gallery" href="{comRef}" title="Obverse of {@identifier}: {@collection}" id="{@uri}">
					<xsl:if test="$position &gt; 1">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<img src="{comRef}" style="max-width:240px"/>
				</a>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
