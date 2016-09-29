<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xxforms="http://orbeon.org/oxf/xml/xforms">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>	
	
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/nomisma/dump/nomisma.org.rdf</url>
				<content-type>application/xml</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="rdf"/>
	</p:processor>
	
	<p:processor name="oxf:identity">
		<p:input name="data" href="aggregate('content', #rdf, ../../config.xml)"/>		
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>
