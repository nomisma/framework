<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: September 2021
	Function: serialize RDF/XML into KML, including SPARQL queries for related findspots and mints
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
	
	<!-- execute SPARQL queries -->
	<p:processor name="oxf:pipeline">		
		<p:input name="config" href="../../../models/sparql/getMints.xpl"/>
		<p:output name="data" id="mints"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/sparql/getHoards.xpl"/>
		<p:output name="data" id="hoards"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/sparql/getFindspots.xpl"/>
		<p:output name="data" id="findspots"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="mints" href="#mints"/>
		<p:input name="hoards" href="#hoards"/>
		<p:input name="findspots" href="#findspots"/>
		<p:input name="data" href="aggregate('ignore', #data)"/>		
		<p:input name="config" href="../../../../ui/xslt/serializations/rdf/kml.xsl"/>
		<p:output name="data" ref="data"/>		
	</p:processor>

	<!--<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<!-\-<content-type>application/xml</content-type>-\->
				<content-type>application/vnd.google-earth.kml+xml</content-type>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>-->
</p:config>