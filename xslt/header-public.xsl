<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="#all" version="2.0">
	<xsl:template name="header-public">
		<div id="hd" xmlns="http://www.w3.org/1999/xhtml">
			<div id="banner">header <xsl:if test="$pipeline='display'">
					<span class="edit-me">
						<a href="{$display_path}admin/edit/?id={substring-after(translate(/xhtml:div/@about, '[]', ''), 'nm:')}">edit id</a>
					</span>
				</xsl:if></div>
			<ul role="menubar" id="menu" class="menubar ui-menubar ui-widget-header ui-helper-clearfix">
				<li role="presentation" class="ui-menubar-item">
					<a aria-haspopup="true" role="menuitem" class="ui-button ui-widget ui-button-text-only ui-menubar-link" tabindex="-1" href="{$display_path}.">
						<span class="ui-button-text">Home</span>
					</a>
				</li>

				<li role="presentation" class="ui-menubar-item">
					<a aria-haspopup="true" role="menuitem" class="ui-button ui-widget ui-button-text-only ui-menubar-link" tabindex="-1" href="{$display_path}browse/">
						<span class="ui-button-text">Browse</span>
					</a>
				</li>
			</ul>
		</div>
	</xsl:template>
</xsl:stylesheet>
