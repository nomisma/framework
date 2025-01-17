<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: January 2025
	Function: Aggregate mints, findspots, and hoards for a SPARQL query in the discover interface
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
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="getMints.xpl"/>
		<p:output name="data" id="mints"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="getHoards.xpl"/>
		<p:output name="data" id="hoards"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="getFindspots.xpl"/>
		<p:output name="data" id="findspots"/>
	</p:processor>

	<p:processor name="oxf:identity">
		<p:input name="data" href="aggregate('discover', #mints, #hoards, #findspots)"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
