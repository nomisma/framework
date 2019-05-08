<?xml version="1.0" encoding="UTF-8"?> 
<!-- Author: Ethan Gruber
	Date: May 2019
	Function: combine editor RDF and SPARQL response for related SKOS concepts and serialize into Crossref.org-compliant XML schema -->

<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
		
	<!-- initiate the XSLT transformation -->
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="config-xml" href="../../../../config.xml"/>
		<p:input name="data" href="#data"/>		
		<p:input name="config" href="../../../../ui/xslt/serializations/sparql/crossref.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/xml</content-type>
				<indent>true</indent>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
