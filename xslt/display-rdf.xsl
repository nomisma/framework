<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:h="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/XSL/Transform"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">


	<!-- Version 0.21 by Fabien.Gandon@sophia.inria.fr -->
	<!-- This software is distributed under either the CeCILL-C license or the GNU Lesser General Public License version 3 license. -->
	<!-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License -->
	<!-- as published by the Free Software Foundation version 3 of the License or under the terms of the CeCILL-C license. -->
	<!-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied -->
	<!-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. -->
	<!-- See the GNU Lesser General Public License version 3 at http://www.gnu.org/licenses/  -->
	<!-- and the CeCILL-C license at http://www.cecill.info/licences/Licence_CeCILL-C_V1-en.html for more details -->


	<xsl:output indent="yes" method="xml" media-type="application/rdf+xml" encoding="UTF-8" omit-xml-declaration="yes"/>

	<!-- base of the current HTML doc -->

	<xsl:variable name="html_base" select="//*/h:head/h:base[position()=1]/@href"/>

	<!-- default HTML vocabulary namespace -->
	<xsl:variable name="default_voc" select="'http://www.w3.org/1999/xhtml/vocab#'"/>

	<!-- url of the current XHTML page if provided by the XSLT engine -->
	<xsl:param name="url" select="''"/>

	<!-- this contains the URL of the source document whether it was provided by the base or as a parameter e.g. http://example.org/bla/file.html-->
	<xsl:variable name="this">
		<xsl:choose>
			<xsl:when test="string-length($html_base)>0">
				<xsl:value-of select="$html_base"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$url"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:variable>

	<!-- this_location contains the location the source document e.g. http://example.org/bla/ -->
	<xsl:variable name="this_location">
		<xsl:call-template name="get-location">
			<xsl:with-param name="url" select="$this"/>
		</xsl:call-template>
	</xsl:variable>

	<!-- this_root contains the root location of the source document e.g. http://example.org/ -->
	<xsl:variable name="this_root">
		<xsl:call-template name="get-root">
			<xsl:with-param name="url" select="$this"/>
		</xsl:call-template>
	</xsl:variable>


	<!-- templates for parsing - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<!--Start the RDF generation-->
	<xsl:template match="/">
		<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
			<xsl:apply-templates mode="rdf2rdfxml"/>
			<!-- the mode is used to ease integration with other XSLT templates -->
		</rdf:RDF>
	</xsl:template>

	<!-- match RDFa element -->
	<xsl:template match="*[attribute::property or attribute::rel or attribute::rev or attribute::typeof]" mode="rdf2rdfxml">

		<!-- identify suject -->
		<xsl:variable name="subject">
			<xsl:call-template name="subject"/>
		</xsl:variable>



		<!-- do we have object properties? -->
		<xsl:if test="string-length(@rel)>0 or string-length(@rev)>0">
			<xsl:variable name="object">
				<!-- identify the object(s) -->
				<xsl:choose>
					<xsl:when test="@resource">
						<xsl:call-template name="expand-curie-or-uri">
							<xsl:with-param name="curie_or_uri" select="@resource"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="@href">
						<xsl:call-template name="expand-curie-or-uri">
							<xsl:with-param name="curie_or_uri" select="@href"/>
						</xsl:call-template>

					</xsl:when>
					<xsl:when
						test="descendant::*[attribute::about or attribute::src or attribute::typeof or
	     	 attribute::href or attribute::resource or
	     	 attribute::rel or attribute::rev or attribute::property]">
						<xsl:call-template name="recurse-objects"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="self-curie-or-uri">
							<xsl:with-param name="node" select="."/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>


			<xsl:call-template name="relrev">
				<xsl:with-param name="subject" select="$subject"/>
				<xsl:with-param name="object" select="$object"/>
			</xsl:call-template>

		</xsl:if>


		<!-- do we have data properties ? -->
		<xsl:if test="string-length(@property)>0">

			<!-- identify language -->
			<xsl:variable name="language" select="string(ancestor-or-self::*/attribute::xml:lang[position()=1])"/>


			<xsl:variable name="expended-pro">
				<xsl:call-template name="expand-ns">
					<xsl:with-param name="qname" select="@property"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="@content">
					<!-- there is a specific content -->
					<xsl:call-template name="property">
						<xsl:with-param name="subject" select="$subject"/>
						<xsl:with-param name="object" select="@content"/>
						<xsl:with-param name="datatype">
							<xsl:choose>

								<xsl:when test="@datatype='' or not(@datatype)"/>
								<!-- enforcing plain literal -->
								<xsl:otherwise>
									<xsl:call-template name="expand-ns">
										<xsl:with-param name="qname" select="@datatype"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="predicate" select="@property"/>
						<xsl:with-param name="attrib" select="'true'"/>
						<xsl:with-param name="language" select="$language"/>
					</xsl:call-template>
				</xsl:when>

				<xsl:when test="not(*)">
					<!-- there no specific content but there are no children elements in the content -->
					<xsl:call-template name="property">
						<xsl:with-param name="subject" select="$subject"/>
						<xsl:with-param name="object" select="."/>
						<xsl:with-param name="datatype">
							<xsl:choose>
								<xsl:when test="@datatype='' or not(@datatype)"/>
								<!-- enforcing plain literal -->
								<xsl:otherwise>
									<xsl:call-template name="expand-ns">
										<xsl:with-param name="qname" select="@datatype"/>
									</xsl:call-template>
								</xsl:otherwise>

							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="predicate" select="@property"/>
						<xsl:with-param name="attrib" select="'true'"/>
						<xsl:with-param name="language" select="$language"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- there is no specific content; we use the value of element -->
					<xsl:call-template name="property">

						<xsl:with-param name="subject" select="$subject"/>
						<xsl:with-param name="object" select="."/>
						<xsl:with-param name="datatype">
							<xsl:choose>
								<xsl:when test="@datatype='' or not(@datatype)">http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral</xsl:when>
								<!-- enforcing XML literal -->
								<xsl:otherwise>
									<xsl:call-template name="expand-ns">
										<xsl:with-param name="qname" select="@datatype"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>

						<xsl:with-param name="predicate" select="@property"/>
						<xsl:with-param name="attrib" select="'false'"/>
						<xsl:with-param name="language" select="$language"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!-- do we have classes ? -->
		<xsl:if test="@typeof">

			<xsl:call-template name="class">
				<xsl:with-param name="resource">
					<xsl:call-template name="self-curie-or-uri">
						<xsl:with-param name="node" select="."/>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="class" select="@typeof"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates mode="rdf2rdfxml"/>

	</xsl:template>



	<!-- named templates to process URIs and token lists - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<!-- tokenize a string using space as a delimiter -->
	<xsl:template name="tokenize">
		<xsl:param name="string"/>
		<xsl:if test="string-length($string)>0">
			<xsl:choose>
				<xsl:when test="contains($string,' ')">
					<xsl:value-of select="normalize-space(substring-before($string,' '))"/>
					<xsl:call-template name="tokenize">
						<xsl:with-param name="string" select="normalize-space(substring-after($string,' '))"/>
					</xsl:call-template>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="$string"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- get file location from URL -->
	<xsl:template name="get-location">
		<xsl:param name="url"/>
		<xsl:if test="string-length($url)>0 and contains($url,'/')">

			<xsl:value-of select="concat(substring-before($url,'/'),'/')"/>
			<xsl:call-template name="get-location">
				<xsl:with-param name="url" select="substring-after($url,'/')"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- get root location from URL -->
	<xsl:template name="get-root">
		<xsl:param name="url"/>
		<xsl:choose>

			<xsl:when test="contains($url,'//')">
				<xsl:value-of select="concat(substring-before($url,'//'),'//',substring-before(substring-after($url,'//'),'/'),'/')"/>
			</xsl:when>
			<xsl:otherwise>UNKNOWN ROOT</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- return namespace of a qname -->
	<xsl:template name="return-ns">

		<xsl:param name="qname"/>
		<xsl:variable name="ns_prefix" select="substring-before($qname,':')"/>
		<xsl:if test="string-length($ns_prefix)>0">
			<!-- prefix must be explicit -->
			<xsl:variable name="name" select="substring-after($qname,':')"/>
			<xsl:value-of select="ancestor-or-self::*/namespace::*[name()=$ns_prefix][position()=1]"/>
		</xsl:if>
		<xsl:if test="string-length($ns_prefix)=0 and ancestor-or-self::*/namespace::*[name()=''][position()=1]">
			<!-- no prefix -->
			<xsl:variable name="name" select="substring-after($qname,':')"/>

			<xsl:value-of select="ancestor-or-self::*/namespace::*[name()=''][position()=1]"/>
		</xsl:if>
	</xsl:template>


	<!-- expand namespace of a qname -->
	<xsl:template name="expand-ns">
		<xsl:param name="qname"/>
		<xsl:variable name="ns_prefix" select="substring-before($qname,':')"/>
		<xsl:if test="string-length($ns_prefix)>0">
			<!-- prefix must be explicit -->

			<xsl:variable name="name" select="substring-after($qname,':')"/>
			<xsl:variable name="ns_uri" select="ancestor-or-self::*/namespace::*[name()=$ns_prefix][position()=1]"/>
			<xsl:value-of select="concat($ns_uri,$name)"/>
		</xsl:if>
		<xsl:if test="string-length($ns_prefix)=0 and ancestor-or-self::*/namespace::*[name()=''][position()=1]">
			<!-- no prefix -->
			<xsl:variable name="name" select="substring-after($qname,':')"/>
			<xsl:variable name="ns_uri" select="ancestor-or-self::*/namespace::*[name()=''][position()=1]"/>
			<xsl:value-of select="concat($ns_uri,$name)"/>

		</xsl:if>
	</xsl:template>

	<!-- determines the CURIE / URI of a node -->
	<xsl:template name="self-curie-or-uri">
		<xsl:param name="node"/>
		<xsl:choose>
			<xsl:when test="$node/attribute::about">
				<!-- we have an about attribute to extend -->
				<xsl:call-template name="expand-curie-or-uri">
					<xsl:with-param name="curie_or_uri" select="$node/attribute::about"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:when test="$node/attribute::src">
				<!-- we have an src attribute to extend -->
				<xsl:call-template name="expand-curie-or-uri">
					<xsl:with-param name="curie_or_uri" select="$node/attribute::src"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$node/attribute::resource and not($node/attribute::rel or $node/attribute::rev)">
				<!-- enforcing the resource as subject if no rel or rev -->
				<xsl:call-template name="expand-curie-or-uri">
					<xsl:with-param name="curie_or_uri" select="$node/attribute::resource"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$node/attribute::href and not($node/attribute::rel or $node/attribute::rev)">
				<!-- enforcing the href as subject if no rel or rev -->

				<xsl:call-template name="expand-curie-or-uri">
					<xsl:with-param name="curie_or_uri" select="$node/attribute::href"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$node/self::h:head or $node/self::h:body or $node/self::h:html">
				<xsl:value-of select="$this"/>
			</xsl:when>
			<!-- enforcing the doc as subject -->
			<xsl:when test="$node/attribute::id">
				<!-- we have an id attribute to extend -->
				<xsl:value-of select="concat($this,'#',$node/attribute::id)"/>
			</xsl:when>
			<xsl:otherwise>blank:node:<xsl:value-of select="generate-id($node)"/></xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<!-- expand CURIE / URI -->
	<xsl:template name="expand-curie-or-uri">
		<xsl:param name="curie_or_uri"/>
		<xsl:choose>
			<xsl:when test="starts-with($curie_or_uri,'[_:')">
				<!-- we have a CURIE blank node -->
				<xsl:value-of select="concat('blank:node:',substring-after(substring-before($curie_or_uri,']'),'[_:'))"/>
			</xsl:when>
			<xsl:when test="starts-with($curie_or_uri,'[')">
				<!-- we have a CURIE between square brackets -->

				<xsl:call-template name="expand-ns">
					<xsl:with-param name="qname" select="substring-after(substring-before($curie_or_uri,']'),'[')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="starts-with($curie_or_uri,'#')">
				<!-- we have an anchor -->
				<xsl:value-of select="concat($this,$curie_or_uri)"/>
			</xsl:when>
			<xsl:when test="string-length($curie_or_uri)=0">
				<!-- empty anchor means the document itself -->
				<xsl:value-of select="$this"/>
			</xsl:when>

			<xsl:when test="not(starts-with($curie_or_uri,'[')) and contains($curie_or_uri,':')">
				<!-- it is a URI -->
				<xsl:value-of select="$curie_or_uri"/>
			</xsl:when>
			<xsl:when test="not(contains($curie_or_uri,'://')) and not(starts-with($curie_or_uri,'/'))">
				<!-- relative URL -->
				<xsl:value-of select="concat($this_location,$curie_or_uri)"/>
			</xsl:when>
			<xsl:when test="not(contains($curie_or_uri,'://')) and (starts-with($curie_or_uri,'/'))">
				<!-- URL from root domain -->
				<xsl:value-of select="concat($this_root,substring-after($curie_or_uri,'/'))"/>

			</xsl:when>
			<xsl:otherwise>UNKNOWN CURIE URI</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- returns the first token in a list separated by spaces -->
	<xsl:template name="get-first-token">
		<xsl:param name="tokens"/>
		<xsl:if test="string-length($tokens)>0">
			<xsl:choose>

				<xsl:when test="contains($tokens,' ')">
					<xsl:value-of select="normalize-space(substring-before($tokens,' '))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tokens"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- returns the namespace for an object property -->
	<xsl:template name="get-relrev-ns">

		<xsl:param name="qname"/>
		<xsl:variable name="ns_prefix" select="substring-before(translate($qname,'[]',''),':')"/>
		<xsl:choose>
			<xsl:when test="string-length($ns_prefix)>0">
				<xsl:call-template name="return-ns">
					<xsl:with-param name="qname" select="$qname"/>
				</xsl:call-template>
			</xsl:when>
			<!-- returns default_voc if the predicate is a reserved value -->
			<xsl:otherwise>
				<xsl:variable name="is-reserved">
					<xsl:call-template name="check-reserved">
						<xsl:with-param name="nonprefixed">
							<xsl:call-template name="no-leading-colon">
								<xsl:with-param name="name" select="$qname"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>

				<xsl:if test="$is-reserved='true'">
					<xsl:value-of select="$default_voc"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- returns the namespace for a data property -->
	<xsl:template name="get-property-ns">
		<xsl:param name="qname"/>
		<xsl:variable name="ns_prefix" select="substring-before(translate($qname,'[]',''),':')"/>

		<xsl:choose>
			<xsl:when test="string-length($ns_prefix)>0">
				<xsl:call-template name="return-ns">
					<xsl:with-param name="qname" select="$qname"/>
				</xsl:call-template>
			</xsl:when>
			<!-- returns default_voc otherwise -->
			<xsl:otherwise>
				<xsl:value-of select="$default_voc"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- returns the qname for a predicate -->
	<xsl:template name="get-predicate-name">
		<xsl:param name="qname"/>
		<xsl:variable name="clean_name" select="translate($qname,'[]','')"/>
		<xsl:call-template name="no-leading-colon">
			<xsl:with-param name="name" select="$clean_name"/>
		</xsl:call-template>
	</xsl:template>

	<!-- no leading colon -->
	<xsl:template name="no-leading-colon">

		<xsl:param name="name"/>
		<xsl:choose>
			<xsl:when test="starts-with($name,':')">
				<!-- remove leading colons -->
				<xsl:value-of select="substring-after($name,':')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- check if a predicate is reserved -->
	<xsl:template name="check-reserved">
		<xsl:param name="nonprefixed"/>
		<xsl:choose>
			<xsl:when test="$nonprefixed='alternate' or $nonprefixed='appendix' or $nonprefixed='bookmark' or $nonprefixed='cite'">true</xsl:when>
			<xsl:when test="$nonprefixed='chapter' or $nonprefixed='contents' or $nonprefixed='copyright' or $nonprefixed='first'">true</xsl:when>
			<xsl:when test="$nonprefixed='glossary' or $nonprefixed='help' or $nonprefixed='icon' or $nonprefixed='index'">true</xsl:when>

			<xsl:when test="$nonprefixed='last' or $nonprefixed='license' or $nonprefixed='meta' or $nonprefixed='next'">true</xsl:when>
			<xsl:when test="$nonprefixed='p3pv1' or $nonprefixed='prev' or $nonprefixed='role' or $nonprefixed='section'">true</xsl:when>
			<xsl:when test="$nonprefixed='stylesheet' or $nonprefixed='subsection' or $nonprefixed='start' or $nonprefixed='top'">true</xsl:when>
			<xsl:when test="$nonprefixed='up'">true</xsl:when>
			<xsl:when test="$nonprefixed='made' or $nonprefixed='previous' or $nonprefixed='search'">true</xsl:when>
			<!-- added because they are frequent -->
			<xsl:otherwise>false</xsl:otherwise>

		</xsl:choose>
	</xsl:template>

	<!-- named templates to generate RDF - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<xsl:template name="recursive-copy">
		<!-- full copy -->
		<xsl:copy>
			<xsl:for-each select="node()|attribute::* ">
				<xsl:call-template name="recursive-copy"/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>


	<xsl:template name="subject">
		<!-- determines current subject -->

		<xsl:choose>

			<!-- current node is a meta or a link in the head and with no about attribute -->
			<xsl:when test="(self::h:link or self::h:meta) and ( ancestor::h:head ) and not(attribute::about)">
				<xsl:value-of select="$this"/>
			</xsl:when>

			<!-- an attribute about was specified on the node -->
			<xsl:when test="self::*/attribute::about">
				<xsl:call-template name="expand-curie-or-uri">
					<xsl:with-param name="curie_or_uri" select="@about"/>
				</xsl:call-template>

			</xsl:when>

			<!-- an attribute src was specified on the node -->
			<xsl:when test="self::*/attribute::src">
				<xsl:call-template name="expand-curie-or-uri">
					<xsl:with-param name="curie_or_uri" select="@src"/>
				</xsl:call-template>
			</xsl:when>


			<!-- an attribute typeof was specified on the node -->
			<xsl:when test="self::*/attribute::typeof">
				<xsl:call-template name="self-curie-or-uri">
					<xsl:with-param name="node" select="."/>
				</xsl:call-template>

			</xsl:when>

			<!-- current node is a meta or a link in the body and with no about attribute -->
			<xsl:when test="(self::h:link or self::h:meta) and not( ancestor::h:head ) and not(attribute::about)">
				<xsl:call-template name="self-curie-or-uri">
					<xsl:with-param name="node" select="parent::*"/>
				</xsl:call-template>
			</xsl:when>

			<!-- an about was specified on its parent or the parent had a rel or a rev attribute but no href or an typeof. -->
			<xsl:when test="ancestor::*[attribute::about or attribute::src or attribute::typeof or attribute::resource or attribute::href or attribute::rel or attribute::rev][position()=1]">
				<xsl:variable name="selected_ancestor"
					select="ancestor::*[attribute::about or attribute::src or attribute::typeof or attribute::resource or attribute::href or attribute::rel or attribute::rev][position()=1]"/>
				<xsl:choose>

					<xsl:when test="$selected_ancestor[(attribute::rel or attribute::rev) and not (attribute::resource or attribute::href)]">
						<xsl:value-of select="concat('blank:node:INSIDE_',generate-id($selected_ancestor))"/>
					</xsl:when>
					<xsl:when test="$selected_ancestor/attribute::about">
						<xsl:call-template name="expand-curie-or-uri">
							<xsl:with-param name="curie_or_uri" select="$selected_ancestor/attribute::about"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$selected_ancestor/attribute::src">
						<xsl:call-template name="expand-curie-or-uri">
							<xsl:with-param name="curie_or_uri" select="$selected_ancestor/attribute::src"/>
						</xsl:call-template>
					</xsl:when>

					<xsl:when test="$selected_ancestor/attribute::resource">
						<xsl:call-template name="expand-curie-or-uri">
							<xsl:with-param name="curie_or_uri" select="$selected_ancestor/attribute::resource"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$selected_ancestor/attribute::href">
						<xsl:call-template name="expand-curie-or-uri">
							<xsl:with-param name="curie_or_uri" select="$selected_ancestor/attribute::href"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="self-curie-or-uri">
							<xsl:with-param name="node" select="$selected_ancestor"/>
						</xsl:call-template>
					</xsl:otherwise>

				</xsl:choose>
			</xsl:when>

			<xsl:otherwise>
				<!-- it must be about the current document -->
				<xsl:value-of select="$this"/>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:template>

	<!-- recursive call for object(s) of object properties -->

	<xsl:template name="recurse-objects">
		<xsl:for-each select="child::*">
			<xsl:choose>
				<xsl:when test="attribute::about or attribute::src">
					<!-- there is a known resource -->
					<xsl:call-template name="expand-curie-or-uri">
						<xsl:with-param name="curie_or_uri" select="attribute::about | attribute::src"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
				</xsl:when>
				<xsl:when test="(attribute::resource or attribute::href) and ( not (attribute::rel or attribute::rev or attribute::property))">
					<!-- there is an incomplet triple -->

					<xsl:call-template name="expand-curie-or-uri">
						<xsl:with-param name="curie_or_uri" select="attribute::resource | attribute::href"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
				</xsl:when>
				<xsl:when test="attribute::typeof and not (attribute::about)">
					<!-- there is an implicit resource -->
					<xsl:call-template name="self-curie-or-uri">
						<xsl:with-param name="node" select="."/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
				</xsl:when>
				<xsl:when test="attribute::rel or attribute::rev or attribute::property">
					<!-- there is an implicit resource -->
					<xsl:if test="not (preceding-sibling::*[attribute::rel or attribute::rev or attribute::property])">
						<!-- generate the triple only once -->

						<xsl:call-template name="subject"/>
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<!-- nothing at that level thus consider children -->
					<xsl:call-template name="recurse-objects"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

	</xsl:template>

	<!-- generate recursive call for multiple objects in rel or rev -->
	<xsl:template name="relrev">
		<xsl:param name="subject"/>
		<xsl:param name="object"/>

		<!-- test for multiple predicates -->
		<xsl:variable name="single-object">
			<xsl:call-template name="get-first-token">
				<xsl:with-param name="tokens" select="$object"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="string-length(@rel)>0">
			<xsl:call-template name="relation">

				<xsl:with-param name="subject" select="$subject"/>
				<xsl:with-param name="object" select="$single-object"/>
				<xsl:with-param name="predicate" select="@rel"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="string-length(@rev)>0">
			<xsl:call-template name="relation">
				<xsl:with-param name="subject" select="$single-object"/>
				<xsl:with-param name="object" select="$subject"/>

				<xsl:with-param name="predicate" select="@rev"/>
			</xsl:call-template>
		</xsl:if>

		<!-- recursive call for multiple predicates -->
		<xsl:variable name="other-objects" select="normalize-space(substring-after($object,' '))"/>
		<xsl:if test="string-length($other-objects)>0">
			<xsl:call-template name="relrev">
				<xsl:with-param name="subject" select="$subject"/>
				<xsl:with-param name="object" select="$other-objects"/>

			</xsl:call-template>
		</xsl:if>

	</xsl:template>


	<!-- generate an RDF statement for a relation -->
	<xsl:template name="relation">
		<xsl:param name="subject"/>
		<xsl:param name="predicate"/>
		<xsl:param name="object"/>

		<!-- test for multiple predicates -->

		<xsl:variable name="single-predicate">
			<xsl:call-template name="get-first-token">
				<xsl:with-param name="tokens" select="$predicate"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- get namespace of the predicate -->
		<xsl:variable name="predicate-ns">
			<xsl:call-template name="get-relrev-ns">
				<xsl:with-param name="qname" select="$single-predicate"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- get name of the predicate -->
		<xsl:variable name="predicate-name">
			<xsl:call-template name="get-predicate-name">
				<xsl:with-param name="qname" select="$single-predicate"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($predicate-ns)>0">
				<!-- there is a known namespace for the predicate -->
				<xsl:element name="rdf:Description" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

					<xsl:choose>
						<xsl:when test="starts-with($subject,'blank:node:')">
							<xsl:attribute name="rdf:nodeID">
								<xsl:value-of select="substring-after($subject,'blank:node:')"/>
							</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="rdf:about">
								<xsl:value-of select="$subject"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:element name="{$predicate-name}" namespace="{$predicate-ns}">
						<xsl:choose>
							<xsl:when test="starts-with($object,'blank:node:')">
								<xsl:attribute name="rdf:nodeID">
									<xsl:value-of select="substring-after($object,'blank:node:')"/>
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="rdf:resource">
									<xsl:value-of select="$object"/>
								</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<!-- no namespace generate a comment for debug -->
				<xsl:comment>No namespace for the rel or rev value ; could not produce the triple for: <xsl:value-of select="$subject"/> - <xsl:value-of select="$single-predicate"/> - <xsl:value-of
						select="$object"/></xsl:comment>
			</xsl:otherwise>

		</xsl:choose>

		<!-- recursive call for multiple predicates -->
		<xsl:variable name="other-predicates" select="normalize-space(substring-after($predicate,' '))"/>
		<xsl:if test="string-length($other-predicates)>0">
			<xsl:call-template name="relation">
				<xsl:with-param name="subject" select="$subject"/>
				<xsl:with-param name="predicate" select="$other-predicates"/>
				<xsl:with-param name="object" select="$object"/>

			</xsl:call-template>
		</xsl:if>

	</xsl:template>


	<!-- generate an RDF statement for a property -->
	<xsl:template name="property">
		<xsl:param name="subject"/>
		<xsl:param name="predicate"/>
		<xsl:param name="object"/>

		<xsl:param name="datatype"/>
		<xsl:param name="attrib"/>
		<!-- is the content from an attribute ? true /false -->
		<xsl:param name="language"/>

		<!-- test for multiple predicates -->
		<xsl:variable name="single-predicate">
			<xsl:call-template name="get-first-token">
				<xsl:with-param name="tokens" select="$predicate"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- get namespace of the predicate -->
		<xsl:variable name="predicate-ns">
			<xsl:call-template name="get-property-ns">
				<xsl:with-param name="qname" select="$single-predicate"/>
			</xsl:call-template>
		</xsl:variable>


		<!-- get name of the predicate -->

		<xsl:variable name="predicate-name">
			<xsl:call-template name="get-predicate-name">
				<xsl:with-param name="qname" select="$single-predicate"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="string-length($predicate-ns)>0">
				<!-- there is a known namespace for the predicate -->
				<xsl:element name="rdf:Description" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
					<xsl:choose>
						<xsl:when test="starts-with($subject,'blank:node:')">
							<xsl:attribute name="rdf:nodeID">
								<xsl:value-of select="substring-after($subject,'blank:node:')"/>
							</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="rdf:about">
								<xsl:value-of select="$subject"/>
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:element name="{$predicate-name}" namespace="{$predicate-ns}">
						<xsl:if test="string-length($language)>0">
							<xsl:attribute name="xml:lang">
								<xsl:value-of select="$language"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="$datatype='http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral'">
								<xsl:choose>
									<xsl:when test="$attrib='true'">
										<!-- content is in an attribute -->
										<xsl:attribute name="rdf:datatype">
											<xsl:value-of select="$datatype"/>
										</xsl:attribute>
										<xsl:value-of select="normalize-space(string($object))"/>

									</xsl:when>
									<xsl:otherwise>
										<!-- content is in the element and may include some tags -->
										<!-- On a property element, only one of the attributes rdf:parseType or rdf:datatype is permitted.
	         	      <xsl:attribute name="rdf:datatype"><xsl:value-of select="$datatype" /></xsl:attribute> -->
										<xsl:attribute name="rdf:parseType">
											<xsl:value-of select="'Literal'"/>
										</xsl:attribute>
										<xsl:for-each select="$object/node()">
											<xsl:call-template name="recursive-copy"/>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>

							</xsl:when>
							<xsl:when test="string-length($datatype)>0">
								<!-- there is a datatype other than XMLLiteral -->
								<xsl:attribute name="rdf:datatype">
									<xsl:value-of select="$datatype"/>
								</xsl:attribute>
								<xsl:choose>
									<xsl:when test="$attrib='true'">
										<!-- content is in an attribute -->
										<xsl:value-of select="normalize-space(string($object))"/>
									</xsl:when>

									<xsl:otherwise>
										<!-- content is in the text nodes of the element -->
										<xsl:value-of select="normalize-space($object)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<!-- there is no datatype -->
								<xsl:choose>
									<xsl:when test="$attrib='true'">
										<!-- content is in an attribute -->

										<xsl:value-of select="normalize-space(string($object))"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- content is in the text nodes of the element -->
										<xsl:attribute name="rdf:parseType">
											<xsl:value-of select="'Literal'"/>
										</xsl:attribute>
										<xsl:for-each select="$object/node()">
											<xsl:call-template name="recursive-copy"/>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>

						</xsl:choose>
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<!-- generate a comment for debug -->
				<xsl:comment>Could not produce the triple for: <xsl:value-of select="$subject"/> - <xsl:value-of select="$single-predicate"/> - <xsl:value-of select="$object"/></xsl:comment>

			</xsl:otherwise>
		</xsl:choose>

		<!-- recursive call for multiple predicates -->
		<xsl:variable name="other-predicates" select="normalize-space(substring-after($predicate,' '))"/>
		<xsl:if test="string-length($other-predicates)>0">
			<xsl:call-template name="property">
				<xsl:with-param name="subject" select="$subject"/>
				<xsl:with-param name="predicate" select="$other-predicates"/>

				<xsl:with-param name="object" select="$object"/>
				<xsl:with-param name="datatype" select="$datatype"/>
				<xsl:with-param name="attrib" select="$attrib"/>
				<xsl:with-param name="language" select="$language"/>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>



	<!-- generate an RDF statement for a class -->

	<xsl:template name="class">
		<xsl:param name="resource"/>
		<xsl:param name="class"/>

		<!-- case multiple classes -->
		<xsl:variable name="single-class">
			<xsl:call-template name="get-first-token">
				<xsl:with-param name="tokens" select="$class"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- get namespace of the class -->
		<xsl:variable name="class-ns">
			<xsl:call-template name="return-ns">
				<xsl:with-param name="qname" select="$single-class"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="string-length($class-ns)>0">
			<!-- we have a qname for the class -->

			<xsl:variable name="expended-class">
				<xsl:call-template name="expand-ns">
					<xsl:with-param name="qname" select="$single-class"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:element name="rdf:Description" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<xsl:choose>
					<xsl:when test="starts-with($resource,'blank:node:')">
						<xsl:attribute name="rdf:nodeID">
							<xsl:value-of select="substring-after($resource,'blank:node:')"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="rdf:about">
							<xsl:value-of select="$resource"/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:element name="rdf:type" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="$expended-class"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:element>

		</xsl:if>

		<!-- recursive call for multiple classes -->
		<xsl:variable name="other-classes" select="normalize-space(substring-after($class,' '))"/>
		<xsl:if test="string-length($other-classes)>0">
			<xsl:call-template name="class">
				<xsl:with-param name="resource" select="$resource"/>
				<xsl:with-param name="class" select="$other-classes"/>
			</xsl:call-template>
		</xsl:if>

	</xsl:template>


	<!-- ignore the rest of the DOM -->
	<xsl:template match="text()|@*|*" mode="rdf2rdfxml">
		<xsl:apply-templates mode="rdf2rdfxml"/>
	</xsl:template>


</xsl:stylesheet>
