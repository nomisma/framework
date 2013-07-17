<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs" version="2.0">

	<xsl:template name="header">
		<div class="center"> Nomisma.org: [<a href="{$display_path}.">home</a>] [<a href="{$display_path}sparql">sparql</a>] [<a href="{$display_path}apis"
				>apis</a>] [<a href="{$display_path}flickr">flickr machine tags</a>] [<a href="{$display_path}id/">all ids</a>] "Common currency for digital
			numismatics." </div>
	</xsl:template>

	<xsl:template name="footer">
		<div class="center">
			<a href="http://creativecommons.org/licenses/by/3.0/"><img alt="Creative Commons License" style="border-width:0"
					src="http://i.creativecommons.org/l/by/3.0/88x31.png"/></a><br/>Unless specified otherwise, content in <a href="http://nomisma.org"
				xmlns:dc="http://purl.org/dc/elements/1.1/">Nomisma.org</a> is licensed under a <a xmlns:cc="http://creativecommons.org/ns#"
				href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 License</a>. </div>
	</xsl:template>

</xsl:stylesheet>
