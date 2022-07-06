<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: July 2022
	Function: Serialize SPARQL queries for available die studies into JSON	
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

	<p:processor name="oxf:unsafe-xslt">	
		<p:input name="request" href="#request"/>
		<p:input name="config-xml" href="../../../../config.xml"/>
		<p:input name="data" href="#data"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/sparql/get-die-studies.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/json</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
