<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://datacite.org/schema/kernel-4" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:nmo="http://nomisma.org/ontology#" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:nomisma="http://nomisma.org/" xmlns:org="http://www.w3.org/ns/org#" exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="/">
		<resource xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://datacite.org/schema/kernel-4"
			xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd">
			<xsl:apply-templates select="/content/rdf:RDF/foaf:Person"/>
		</resource>
	</xsl:template>

	<xsl:template match="foaf:Person">
		<identifier identifierType="DOI">
			<xsl:value-of select="concat('ID', '/', tokenize(@rdf:about, '/')[last()])"/>
		</identifier>
		<creators>
			<creator>
				<creatorName>
					<xsl:value-of select="skos:prefLabel"/>
				</creatorName>
				<xsl:if test="skos:exactMatch[contains(@rdf:resource, 'orcid.org')]">
					<nameIdentifier schemeURI="http://orcid.org/" nameIdentifierScheme="ORCID">
						<xsl:value-of select="tokenize(skos:exactMatch[contains(@rdf:resource, 'orcid.org')]/@rdf:resource, '/')[last()]"/>
					</nameIdentifier>
				</xsl:if>
				<!-- TODO: Add affiliation -->
			</creator>
		</creators>
		<titles>
			<title xml:lang="en-us">Contributions of <xsl:value-of select="skos:prefLabel"/> to <xsl:value-of select="/content/config/title"/>.</title>
		</titles>
		<publisher>
			<xsl:value-of select="/content/config/datacite/publisher"/>
		</publisher>
		<xsl:if test="doc('input:start-date')//res:binding[@name = 'date']">
			<publicationYear>
				<xsl:value-of select="substring(doc('input:start-date')//res:binding[@name = 'date']/res:literal, 1, 4)"/>
			</publicationYear>
		</xsl:if>
		<dates>
			<date dateType="Updated">
				<xsl:value-of select="substring-before(doc('input:end-date')//res:binding[@name = 'date']/res:literal, 'T')"/>
			</date>
		</dates>
		<language>en</language>
		<resourceType resourceTypeGeneral="Dataset">RDF</resourceType>
		<alternateIdentifiers>
			<alternateIdentifier alternateIdentifierType="URL">
				<xsl:value-of select="@rdf:about"/>
			</alternateIdentifier>
		</alternateIdentifiers>
		
		<formats>
			<format>application/rdf+xml</format>
			<format>application/ld+json</format>
			<format>text/turtle</format>
		</formats>
		<rightsList>
			<xsl:apply-templates select="/content/config/datacite/rights"/>
		</rightsList>
		<descriptions>
			<description xml:lang="en-us" descriptionType="Abstract">Contributions of <xsl:value-of select="skos:prefLabel"/> to <xsl:value-of
					select="/content/config/title"/>. These represent any SKOS Concepts (RDF) created or updated by this editor, by means of batch uploaded
				through Google Sheets or manual editing in the back-end.</description>
		</descriptions>
	</xsl:template>

	<!-- config templates -->
	<xsl:template match="rights">
		<rights rightsURI="{@rightsURI}">
			<xsl:value-of select="."/>
		</rights>
	</xsl:template>
</xsl:stylesheet>
