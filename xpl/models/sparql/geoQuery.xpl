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
		
	<p:choose href="#request">
		<!-- if there are compare request params, call the correct API pipeline based on the type request parameter -->
		<p:when test="/request/parameters/parameter[name='compare']">
			<p:choose href="#request">
				<p:when test="/request/parameters/parameter[name='type']/value = 'mint'">
					<p:processor name="oxf:pipeline">
						<p:input name="config" href="getMints.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="/request/parameters/parameter[name='type']/value = 'hoard'">
					<p:processor name="oxf:pipeline">
						<p:input name="config" href="getHoards.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="/request/parameters/parameter[name='type']/value = 'findspot'">
					<p:processor name="oxf:pipeline">
						<p:input name="config" href="getFindspots.xpl"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:identity">
						<p:input name="data" href="#data"/>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<!-- otherwise, execute the SPARQL query and aggregate mints, hoards, and findspots -->
		<p:when test="/request/parameters/parameter[name='query']">
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
		</p:when>
	</p:choose>
	

</p:config>
