<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: December 2021
	Function: Read an XML instance from the Manage datasets XForms interace and serialize into CSV for download
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>	
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#data"/>		
		<p:input name="config" href="../../xforms/xslt/places-to-csv.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>text/csv</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>