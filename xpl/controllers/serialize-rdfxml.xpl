<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: August 2018
	Function: Attach the correct HTTP header content type to RDF/XML serialized from Nomisma namespaces or the ontology	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:xml-converter">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<config>
				<content-type>application/rdf+xml</content-type>
				<encoding>utf-8</encoding>
				<version>1.0</version>
				<indent>true</indent>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
