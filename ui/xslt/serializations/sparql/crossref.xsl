<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.crossref.org/schema/4.4.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:digest="org.apache.commons.codec.digest.DigestUtils" xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all"
	version="2.0">

	<xsl:template match="/">
		<doi_batch version="4.4.0" xmlns="http://www.crossref.org/schema/4.4.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.crossref.org/schema/4.4.0
			http://www.crossref.org/schemas/crossref4.4.0.xsd">

			<!-- head -->
			<xsl:apply-templates select="doc('input:config-xml')/config/crossref"/>

			<!-- body -->
			<body>
				<database>
					<!-- database metadata -->
					<xsl:apply-templates select="doc('input:config-xml')/config"/>
					
					<!-- datasets for each editor -->
					<xsl:apply-templates select="descendant::res:result"/>
				</database>
			</body>

		</doi_batch>
	</xsl:template>

	<xsl:template match="config">
		<database_metadata>
			<titles>
				<title>
					<xsl:value-of select="title"/>
					<xsl:text> thesaurus of numismatic concepts</xsl:text>
				</title>
			</titles>
			<doi_data>
				<doi>
					<xsl:value-of select="concat(crossref/doi_prefix, '/nomisma.org')"/>
				</doi>
				<resource>
					<xsl:value-of select="url"/>
				</resource>
			</doi_data>
		</database_metadata>
	</xsl:template>

	<!-- process every SPARQL result into a separate dataset -->
	<xsl:template match="res:result">
		<dataset>
			<contributors>
				<person_name sequence="first" contributor_role="author">
					<given_name>
						<xsl:value-of select="substring-before(res:binding[@name = 'name']/res:literal, ' ')"/>
					</given_name>
					<surname>
						<xsl:value-of select="substring-after(res:binding[@name = 'name']/res:literal, ' ')"/>
					</surname>
					<format>application/rdf+xml</format>
					<xsl:if test="res:binding[@name = 'orcid']">
						<ORCID>
							<xsl:value-of select="res:binding[@name = 'orcid']/res:uri"/>
						</ORCID>
					</xsl:if>
				</person_name>
			</contributors>
			<doi_data>
				<doi>
					<xsl:value-of select="concat(doc('input:config-xml')/config/crossref/doi_prefix, '/nomisma.org:', tokenize(res:binding[@name = 'editor']/res:uri, '/')[last()])"
					/>
				</doi>
				<resource>
					<xsl:value-of select="res:binding[@name = 'editor']/res:uri"/>
				</resource>
			</doi_data>
		</dataset>
	</xsl:template>

	<!-- config templates -->
	<xsl:template match="crossref">

		<head>
			<!-- batch ID is the document URI encrypted into md5 hash, will be unique -->
			<doi_batch_id>
				<xsl:value-of select="digest:md5Hex(string(parent::node()/url))"/>
			</doi_batch_id>
			<!-- timestamp is seconds from 1970 (rounded up), from https://stackoverflow.com/questions/3467771/convert-datetime-to-unix-epoch-in-xslt -->
			<timestamp>
				<xsl:value-of select="
						ceiling((current-dateTime() - xs:dateTime('1970-01-01T00:00:00'))
						div
						xs:dayTimeDuration('PT1S'))"/>
			</timestamp>
			<depositor>
				<depositor_name>
					<xsl:value-of select="depositor_name"/>
				</depositor_name>
				<email_address>
					<xsl:value-of select="depositor_email"/>
				</email_address>
			</depositor>
			<registrant>
				<xsl:value-of select="registrant"/>
			</registrant>
		</head>
	</xsl:template>
</xsl:stylesheet>
