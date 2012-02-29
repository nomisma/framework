<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:skos="http://www.w3.org/2008/05/skos#" exclude-result-prefixes="#all" version="2.0">
	<xsl:template name="header-public">
		<div id="hd">
			<h1>header</h1>
			<xsl:if test="$pipeline='display'">
				<span style="float:right">
					<a href="{$display_path}admin/edit/?id={tokenize(rdf:RDF/skos:Concept/@rdf:about, '/')[last()]}">edit id</a>
				</span>
			</xsl:if>
		</div>
	</xsl:template>
</xsl:stylesheet>
