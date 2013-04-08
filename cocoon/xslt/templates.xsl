<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs" version="2.0">

	<xsl:template name="header">
		<div class="center">
			Nomisma.org: [<a href="{$display_path}.">home</a>] [<a href="{$display_path}sparql">sparql</a>] "Common currency for digital numismatics." 
		</div>
	</xsl:template>

	<xsl:template name="footer">
		<div class="center">
			<a href="http://creativecommons.org/licenses/by/3.0/"><img alt="Creative Commons License" style="border-width:0"
					src="http://i.creativecommons.org/l/by/3.0/88x31.png"/></a><br/>Unless specified otherwise, content in <span
				xmlns:dc="http://purl.org/dc/elements/1.1/">Nomisma.org</span>
			<a xmlns:cc="http://creativecommons.org/ns#" href="http://nomisma.org">http://nomisma.org</a> is licensed under a <a
				href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 License</a>. </div>
		<div class="center" style="border:none;background-color:white;margin-top:0px;margin-bottom:0px">
			<span style="color:gray">All data in nomisma.org is preliminary and in the process of being updated.</span>
		</div>
	</xsl:template>

</xsl:stylesheet>
