<?xml version="1.0" encoding="UTF-8"?>
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="aggregate('content', ../../../config.xml, ../../../content.xml)"/>		
		<p:input name="config" href="../../../ui/xslt/pages/apis.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
	

</p:config>
