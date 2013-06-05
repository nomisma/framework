<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">
	
	<p:param type="input" name="config"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>

