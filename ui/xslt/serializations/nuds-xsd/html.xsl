<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>

	<xsl:variable name="display_path">./</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: Numismatic Description Schema (NUDS)</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<script type="text/javascript" src="https://code.jquery.com/jquery-latest.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/result_functions.js"/>
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>

				<!-- syntax highlighting -->
				<script type="text/javascript" src="{$display_path}ui/javascript/prism.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/prism.css"/>

				<!-- google analytics -->
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid content">
			<div class="row">
				<div class="col-md-12">
					<!-- render the description from the content.xml file -->
					<xsl:copy-of select="/content/content/nuds/*"/>

					<h3>Current Version: <xsl:value-of select="/content/xs:schema/@version"/></h3>

					<!-- process the XSD to develop the table of contents and tag library -->
					<h2>Table of Contents</h2>
					<div id="toc-elements">
						<h3>Elements</h3>
						<xsl:apply-templates select="//xs:schema/xs:element[@name]" mode="toc">
							<xsl:sort select="@name" order="ascending"/>
						</xsl:apply-templates>
					</div>
					<div id="toc-attributes">
						<h3>Attributes</h3>
						<xsl:apply-templates select="//xs:attribute[@name]" mode="toc">
							<xsl:sort select="@name" order="ascending"/>
						</xsl:apply-templates>
					</div>
					<hr/>
					<div>
						<h3>Element List</h3>
						<xsl:apply-templates select="//xs:schema/xs:element[@name]" mode="desc">
							<xsl:sort select="@name" order="ascending"/>
						</xsl:apply-templates>
					</div>
					<div>
						<h3>Attribute List</h3>
						<xsl:apply-templates select="//xs:attribute[@name]" mode="desc">
							<xsl:sort select="@name" order="ascending"/>
						</xsl:apply-templates>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- element/attribute Table of Contents template -->
	<xsl:template match="xs:element | xs:attribute" mode="toc">
		<a href="#{@name}">
			<xsl:value-of select="@name"/>
		</a>
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<!-- element/attribute definition template -->
	<xsl:template match="xs:element|xs:attribute" mode="desc">
		<xsl:variable name="name" select="@name"/>

		<div id="{@name}">
			<h3>
				<xsl:value-of select="@name"/>
				<small style="margin-left:1em">
					<a href="{concat('#toc-', local-name(), 's')}"><span class="glyphicon glyphicon-arrow-up"/>Top</a>
				</small>
			</h3>
			<xsl:apply-templates select="xs:annotation/xs:documentation"/>
			<dl class="dl-horizontal">
				<dt>May Contain</dt>
				<dd>
					<xsl:choose>
						<xsl:when test="xs:complexType">
							<xsl:apply-templates select="xs:complexType"/>
						</xsl:when>
						<xsl:when test="xs:simpleType">
							<xsl:apply-templates select="xs:simpleType"/>
						</xsl:when>
						<xsl:when test="@type">
							<xsl:variable name="type" select="@type"/>
							
							<xsl:apply-templates select="//xs:schema/xs:simpleType[@name=$type]"/>
						</xsl:when>
					</xsl:choose>
				</dd>
				
				<xsl:if test="local-name() = 'element'">
					<!-- for deriving parent and child elements and attributes -->
					<xsl:variable name="parents" as="node()*">
						<parents>
							<xsl:apply-templates select="//xs:schema/descendant::xs:element[@ref = $name]" mode="parents"/>
						</parents>
					</xsl:variable>
					<xsl:variable name="attributes" as="node()*">
						<attributes>
							<xsl:apply-templates select="descendant::xs:attribute | descendant::xs:attributeGroup"/>
						</attributes>
					</xsl:variable>
					
					<dt>May Occur Within</dt>
					<dd>
						<xsl:choose>
							<xsl:when test="count($parents/child) &gt; 0">
								<xsl:call-template name="render-relatives">
									<xsl:with-param name="relatives" select="$parents"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>[root element]</xsl:otherwise>
						</xsl:choose>
					</dd>
					<xsl:if test="count($attributes/child) &gt; 0">
						<dt>Attributes</dt>
						<dd>
							<xsl:call-template name="render-relatives">
								<xsl:with-param name="relatives" select="$attributes"/>
							</xsl:call-template>
						</dd>
					</xsl:if>
				</xsl:if>
				
			</dl>

			<xsl:apply-templates select="/content/examples/example[@name = $name]"/>
			<hr/>
		</div>
	</xsl:template>

	<!-- iterate through parent elements -->
	<xsl:template match="xs:element | xs:group" mode="parents">
		<xsl:choose>
			<xsl:when test="ancestor::xs:element">
				<child>
					<xsl:value-of select="ancestor::xs:element/@name"/>
				</child>
			</xsl:when>
			<xsl:when test="ancestor::xs:group">
				<xsl:variable name="name" select="ancestor::xs:group/@name"/>

				<xsl:apply-templates select="ancestor::xs:schema/descendant::xs:group[@ref = $name]" mode="parents"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- get children elements and content types -->
	<xsl:template match="xs:complexType">
		<xsl:choose>
			<xsl:when test="xs:simpleType or xs:simpleContent or xs:complexContent">
				<!-- display the content type or restricted lists -->
				<xsl:apply-templates select="xs:simpleType | xs:simpleContent | xs:complexContent"/>
			</xsl:when>
			<xsl:when test="@mixed = true()">
				<!-- display text or mixed content options -->
				<xsl:choose>
					<xsl:when test="xs:sequence or xs:choice">
						<xsl:text>mixed [text] and/or </xsl:text>
						<xsl:variable name="children" as="node()*">
							<elements>
								<xsl:apply-templates select="descendant::xs:element | descendant::xs:group"/>
							</elements>
						</xsl:variable>

						<xsl:call-template name="render-relatives">
							<xsl:with-param name="relatives" select="$children"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>[text]</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- display child elements -->
				<xsl:variable name="children" as="node()*">
					<elements>
						<xsl:apply-templates select="descendant::xs:element | descendant::xs:group"/>
					</elements>
				</xsl:variable>

				<xsl:call-template name="render-relatives">
					<xsl:with-param name="relatives" select="$children"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xs:complexContent">
		<xsl:apply-templates select="xs:restriction | xs:extension"/>
	</xsl:template>

	<xsl:template match="xs:simpleType | xs:simpleContent">
		<xsl:apply-templates select="xs:restriction | xs:extension | xs:union"/>
	</xsl:template>

	<xsl:template match="xs:union">
		<xsl:choose>
			<xsl:when test="descendant::xs:enumeration or descendant::xs:pattern">
				<xsl:apply-templates select="descendant::xs:enumeration|descendant::xs:pattern">
					<xsl:sort select="@value"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="xs:simpleType">
					<xsl:apply-templates select="self::node()"/>
					<xsl:if test="not(position()=last())">
						<xsl:text> or </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xs:restriction | xs:extension">
		<xsl:choose>
			<xsl:when test="xs:simpleType">
				<xsl:apply-templates select="xs:simpleType"/>
			</xsl:when>
			<xsl:when test="xs:enumeration">
				<xsl:apply-templates select="xs:enumeration">
					<xsl:sort select="@value"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="contains(@base, 'tei')">
						<!-- TEI extensions -->
						<xsl:variable name="macro" select="substring-after(@base, 'tei_')"/>

						<a href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-{$macro}.html">TEI <xsl:value-of select="$macro"/></a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('[', @base, ']')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xs:enumeration|xs:pattern">
		<xsl:if test="local-name()='pattern'">
			<xsl:text>regex(</xsl:text>
		</xsl:if>
		<xsl:value-of select="concat('&#x022;', @value, '&#x022;')"/>
		<xsl:if test="local-name()='pattern'">
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:if test="not(position() = last())">
			<xsl:text> or </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="xs:documentation">
		<p>
			<xsl:value-of select="normalize-space(.)"/>
		</p>
	</xsl:template>

	<!-- for gathering child elements and attributes as variables -->
	<xsl:template match="xs:group">
		<xsl:variable name="ref" select="@ref"/>

		<xsl:apply-templates select="//xs:group[@name = $ref]/*"/>
	</xsl:template>

	<xsl:template match="xs:element">
		<child>
			<xsl:value-of select="@ref"/>
		</child>
	</xsl:template>

	<xsl:template match="xs:attributeGroup">
		<xsl:variable name="ref" select="@ref"/>

		<xsl:apply-templates select="//xs:attributeGroup[@name = $ref]/xs:attribute"/>
	</xsl:template>

	<xsl:template match="xs:attribute">
		<child>
			<xsl:if test="@use = 'required'">
				<xsl:attribute name="required">true</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="
					if (@name) then
						@name
					else
						@ref"/>
		</child>
	</xsl:template>

	<!-- *********** RENDERING EXAMPLES ************ -->
	<xsl:template match="example">
		<h4>Example</h4>
		<xsl:choose>
			<xsl:when test="@ref">
				<p>See <a href="{@ref}"><xsl:value-of select="substring-after(@ref, '#')"/></a></p>
			</xsl:when>
			<xsl:otherwise>
				<pre>
					<code class="language-markup"><xsl:value-of select="."/></code>
				</pre>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- *********** CUSTOM TEMPLATES ************ -->

	<!-- render child attributes or elements -->
	<xsl:template name="render-relatives">
		<xsl:param name="relatives" as="node()*"/>
		<xsl:variable name="mode" select="$relatives/name()"/>

		<xsl:for-each select="$relatives//child">
			<xsl:sort select="."/>

			<xsl:if test="not(. = preceding-sibling::text())">
				<a href="#{.}">
					<xsl:value-of select="."/>
				</a>
				<xsl:choose>
					<xsl:when test="$mode = 'attributes'">
						<xsl:text>: </xsl:text>
						<xsl:choose>
							<xsl:when test="@required = 'true'">
								<strong>required</strong>
							</xsl:when>
							<xsl:otherwise>optional</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="not(position() = last())">
							<br/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
