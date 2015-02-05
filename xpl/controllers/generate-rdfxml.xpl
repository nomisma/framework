<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xxforms="http://orbeon.org/oxf/xml/xforms">

	<p:param type="input" name="data"/>
	
	<!-- aggregate all RDF/XML into a single model -->
	<p:processor name="oxf:pipeline">
		<p:input name="config-xml" href="../../config.xml"/>
		<p:input name="config" href="../models/rdf/aggregate-all.xpl"/>
		<p:output name="data" id="rdfxml"/>
	</p:processor>
	
	<!-- rdfxml has to be converted back into application/xml -->
	<p:processor name="oxf:xml-converter">
		<p:input name="config">
			<config>
				<method>xml</method>
				<content-type>application/xml</content-type>
				<indent-amount>4</indent-amount>
				<encoding>utf-8</encoding>
				<indent>true</indent>
			</config>
		</p:input>
		<p:input name="data" href="#rdfxml"/>
		<p:output name="data" id="converted"/>				
	</p:processor>
	
	<p:processor name="oxf:file-serializer">
		<p:input name="config">
			<config>
				<url>oxf:/apps/nomisma/dump/nomisma.org.rdf</url>
				<content-type>application/xml</content-type>
				<make-directories>false</make-directories>
				<append>false</append>
			</config>
		</p:input>
		<p:input name="data" href="#converted"/>		
	</p:processor>
</p:pipeline>
