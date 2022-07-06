<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: July 2022
	Function: Execute a series of SPARQL queries to calculate the estimated die counts for a coin type	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<!-- *** OBVERSE QUERIES *** -->
	<!-- specimen count, n -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
				<xsl:param name="dieStudy" select="doc('input:request')/request/parameters/parameter[name='dieStudy']/value"/>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>

				<xsl:variable name="query">
					<![CDATA[PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nm: <http://nomisma.org/id/>
PREFIX nmo: <http://nomisma.org/ontology#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

SELECT (count(?object) as ?count)  WHERE {
  	?object nmo:hasTypeSeriesItem <%typeURI%> .
    GRAPH <%dieStudy%> {
      ?object nmo:hasObverse/nmo:hasDie/rdf:value ?die
    }
}]]></xsl:variable>


				<xsl:variable name="service"
					select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%typeURI%', $type), '%dieStudy%', $dieStudy)), '&amp;output=xml')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="obvCount-url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#obvCount-url-generator-config"/>
		<p:output name="data" id="obvCount"/>
	</p:processor>

	<!-- unique dies, d -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
				<xsl:param name="dieStudy" select="doc('input:request')/request/parameters/parameter[name='dieStudy']/value"/>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>

				<xsl:variable name="query">
					<![CDATA[PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nm: <http://nomisma.org/id/>
PREFIX nmo: <http://nomisma.org/ontology#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

SELECT (count(DISTINCT ?die) as ?count)  WHERE {
  	?object nmo:hasTypeSeriesItem <%typeURI%> .
    GRAPH <%dieStudy%> {
      ?object nmo:hasObverse/nmo:hasDie/rdf:value ?die
    }
}]]></xsl:variable>


				<xsl:variable name="service"
					select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%typeURI%', $type), '%dieStudy%', $dieStudy)), '&amp;output=xml')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="obvUniqueDies-url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#obvUniqueDies-url-generator-config"/>
		<p:output name="data" id="obvUniqueDies"/>
	</p:processor>

	<!-- singleton dies, d1 -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
				<xsl:param name="dieStudy" select="doc('input:request')/request/parameters/parameter[name='dieStudy']/value"/>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>

				<xsl:variable name="query">
					<![CDATA[PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nm: <http://nomisma.org/id/>
PREFIX nmo: <http://nomisma.org/ontology#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

SELECT (count(?die) as ?dieCount) WHERE {
  {
    SELECT DISTINCT ?die (count(?object) as ?count)  WHERE {
        ?object nmo:hasTypeSeriesItem <%typeURI%> .
        GRAPH <%dieStudy%> {
          ?object nmo:hasObverse/nmo:hasDie/rdf:value ?die 
        }
    } GROUP BY ?die HAVING (?count = 1)
  }
}]]></xsl:variable>


				<xsl:variable name="service"
					select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%typeURI%', $type), '%dieStudy%', $dieStudy)), '&amp;output=xml')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="obv-d1-url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#obv-d1-url-generator-config"/>
		<p:output name="data" id="obv-d1"/>
	</p:processor>

	<!-- *** REVERSE QUERIES *** -->
	<!-- specimen count, n -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
				<xsl:param name="dieStudy" select="doc('input:request')/request/parameters/parameter[name='dieStudy']/value"/>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>

				<xsl:variable name="query">
					<![CDATA[PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nm: <http://nomisma.org/id/>
PREFIX nmo: <http://nomisma.org/ontology#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

SELECT (count(?object) as ?count)  WHERE {
  	?object nmo:hasTypeSeriesItem <%typeURI%> .
    GRAPH <%dieStudy%> {
      ?object nmo:hasReverse/nmo:hasDie/rdf:value ?die
    }
}]]></xsl:variable>


				<xsl:variable name="service"
					select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%typeURI%', $type), '%dieStudy%', $dieStudy)), '&amp;output=xml')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="revCount-url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#revCount-url-generator-config"/>
		<p:output name="data" id="revCount"/>
	</p:processor>

	<!-- unique dies, d -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
				<xsl:param name="dieStudy" select="doc('input:request')/request/parameters/parameter[name='dieStudy']/value"/>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>

				<xsl:variable name="query">
					<![CDATA[PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nm: <http://nomisma.org/id/>
PREFIX nmo: <http://nomisma.org/ontology#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

SELECT (count(DISTINCT ?die) as ?count)  WHERE {
  	?object nmo:hasTypeSeriesItem <%typeURI%> .
    GRAPH <%dieStudy%> {
      ?object nmo:hasReverse/nmo:hasDie/rdf:value ?die
    }
}]]></xsl:variable>


				<xsl:variable name="service"
					select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%typeURI%', $type), '%dieStudy%', $dieStudy)), '&amp;output=xml')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="revUniqueDies-url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#revUniqueDies-url-generator-config"/>
		<p:output name="data" id="revUniqueDies"/>
	</p:processor>

	<!-- singleton dies, d1 -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../../../config.xml"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- request parameters -->
				<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
				<xsl:param name="dieStudy" select="doc('input:request')/request/parameters/parameter[name='dieStudy']/value"/>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql_query"/>

				<xsl:variable name="query">
					<![CDATA[PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nm: <http://nomisma.org/id/>
PREFIX nmo: <http://nomisma.org/ontology#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

SELECT (count(?die) as ?dieCount) WHERE {
  {
    SELECT DISTINCT ?die (count(?object) as ?count)  WHERE {
        ?object nmo:hasTypeSeriesItem <%typeURI%> .
        GRAPH <%dieStudy%> {
          ?object nmo:hasReverse/nmo:hasDie/rdf:value ?die 
        }
    } GROUP BY ?die HAVING (?count = 1)
  }
}]]></xsl:variable>


				<xsl:variable name="service"
					select="concat($sparql_endpoint, '?query=', encode-for-uri(replace(replace($query, '%typeURI%', $type), '%dieStudy%', $dieStudy)), '&amp;output=xml')"/>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="rev-d1-url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#rev-d1-url-generator-config"/>
		<p:output name="data" id="rev-d1"/>
	</p:processor>

	<p:processor name="oxf:identity">
		<p:input name="data" href="aggregate('response', #obvCount, #obvUniqueDies, #obv-d1, #revCount, #revUniqueDies, #rev-d1)"/>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
