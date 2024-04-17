<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

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

	<!-- read request parameters to determine the type of response -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<mode>
						<xsl:choose>
							<xsl:when test="/request/parameters/parameter[name='query']/value">query</xsl:when>
							<xsl:when test="/request/parameters/parameter[name='queries']/value">queries</xsl:when>
							<xsl:otherwise>default</xsl:otherwise>
						</xsl:choose>
					</mode>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="query-type"/>
	</p:processor>

	<p:choose href="#query-type">
		<!-- when there is a query parameter, then initiate the pipeline for the Solr query and serialization into the OpenRefine JSON model -->
		<p:when test="/mode = 'query'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
						xmlns:xxf="http://www.orbeon.com/oxf/pipeline">
						<xsl:include href="../../../ui/xslt/serializations/json/reconcile-query.xsl"/>

						<xsl:variable name="q">
							<xsl:variable name="query" as="node()*">
								<xsl:copy-of select="xxf:json-to-xml(doc('input:request')/request/parameters/parameter[name='query']/value)"/>
							</xsl:variable>

							<!-- compile the q parameter -->
							<xsl:apply-templates select="$query/json"/>
						</xsl:variable>

						<!-- config variables -->
						<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
						<xsl:variable name="service" select="concat($solr-url, '?', $q)"/>


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
				<p:output name="data" id="config"/>
			</p:processor>

			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#config"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<!-- parse multiple queries, iterate and aggregate multiple Solr responses -->
		<p:when test="/mode = 'queries'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
						xmlns:xxf="http://www.orbeon.com/oxf/pipeline">

						<xsl:template match="/">
							<xsl:copy-of select="xxf:json-to-xml(doc('input:request')/request/parameters/parameter[name='queries']/value)"/>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="queries"/>
			</p:processor>

			<p:for-each href="#queries" select="/json/*[@type='object']" root="aggregate" id="aggregate">
				<p:processor name="oxf:unsafe-xslt">
					<p:input name="request" href="#request"/>
					<p:input name="data" href="current()"/>
					<p:input name="config-xml" href="../../../config.xml"/>
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
							xmlns:xxf="http://www.orbeon.com/oxf/pipeline">
							<xsl:include href="../../../ui/xslt/serializations/json/reconcile-query.xsl"/>


							<!-- compile the q parameter -->
							<xsl:variable name="q">
								<xsl:apply-templates select="/*[@type='object']"/>
							</xsl:variable>

							<!-- config variables -->
							<xsl:variable name="solr-url" select="concat(doc('input:config-xml')/config/solr_published, 'select/')"/>
							<xsl:variable name="service" select="concat($solr-url, '?', $q)"/>


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
					<p:output name="data" id="config"/>
				</p:processor>

				<p:processor name="oxf:url-generator">
					<p:input name="config" href="#config"/>
					<p:output name="data" ref="aggregate"/>
				</p:processor>
			</p:for-each>

			<p:processor name="oxf:identity">
				<p:input name="data" href="#aggregate"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<!-- otherwise output the JSON service metadata -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">

						<!-- config variables -->
						<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
						<xsl:variable name="service" select="concat($solr-url, '?q=*:*&amp;rows=0&amp;facet=true&amp;facet.field=type')"/>


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
				<p:output name="data" id="config"/>
			</p:processor>

			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#config"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:pipeline>
