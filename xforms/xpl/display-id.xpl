<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>		
		<p:input name="config" href="../xslt/display-id.xsl"/>
		<p:output name="data" id="html"/>
	</p:processor>
	
	<p:processor name="oxf:xml-converter">
		<p:input name="config">
			<config>
				<content-type>text/html</content-type>
				<encoding>utf-8</encoding>
				<version>1.0</version>
				<public-doctype>-//W3C//DTD XHTML+RDFa 1.0//EN</public-doctype>
				<system-doctype>http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd</system-doctype>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:input name="data" href="#html"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>