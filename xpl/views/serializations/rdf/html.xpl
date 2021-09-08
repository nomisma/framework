<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date Last Modified: August 2020
	Function: Serialize an RDF snippet into HTML, including conditionals to execute other SPARQL queries to enhance page context with maps, example types, etc.
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:res="http://www.w3.org/2005/sparql-results#">

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

	<!-- get the namespace/concept scheme of the RDF file -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>

		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

				<xsl:template match="/">
					<scheme>
						<xsl:value-of select="tokenize(/request/request-url, '/')[last() - 1]"/>
					</scheme>
				</xsl:template>

			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="scheme"/>
	</p:processor>

	<!-- evaluate editor vs. id concept scheme -->
	<p:choose href="#scheme">
		<p:when test="/scheme = 'symbol'">
			<!-- Jan. 2020: just serialize the RDF into HTML without further content -->
			
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #data, ../../../../config.xml)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/rdf/html.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:when>		
		<p:when test="/scheme = 'editor'">

			<!-- get the type of the RDF fragment in the editor namespace -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>

				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
						xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

						<xsl:template match="/">
							<type>
								<xsl:value-of select="/rdf:RDF/*[1]/name()"/>
							</type>
						</xsl:template>

					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="type"/>
			</p:processor>

			<p:choose href="#type">
				<p:when test="/type = 'skos:ConceptScheme'">
					<!-- execute SPARQL query to get list of editors -->
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../../models/sparql/getEditors.xpl"/>
						<p:output name="data" id="editors"/>
					</p:processor>

					<!-- aggregate models and serialize into HTML -->
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="editors" href="#editors"/>
						<p:input name="data" href="aggregate('content', #data, ../../../../config.xml)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/rdf/html.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:when>
				<p:when test="/type = 'foaf:Person'">
					<!-- execute SPARQL query to get total count of contributed IDs -->
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#data"/>
						<p:input name="config" href="../../../models/sparql/countEditedIds.xpl"/>
						<p:output name="data" id="id-count"/>
					</p:processor>

					<!-- if there are more than 0, then initiate the next two SPARQL queries to generate lists of spreadsheets and IDs -->
					<p:choose href="#id-count">
						<p:when test="number(//res:binding[@name='count']/res:literal) &gt; 0">
							<!-- get the SPARQL queries for edited IDs and spreadsheets to pass into the HTML serialization -->
							<p:processor name="oxf:url-generator">
								<p:input name="config">
									<config>
										<url>oxf:/apps/nomisma/ui/sparql/getEditedIds.sparql</url>
										<content-type>text/plain</content-type>
										<encoding>utf-8</encoding>
									</config>
								</p:input>
								<p:output name="data" id="getEditedIds-query"/>
							</p:processor>

							<p:processor name="oxf:text-converter">
								<p:input name="data" href="#getEditedIds-query"/>
								<p:input name="config">
									<config/>
								</p:input>
								<p:output name="data" id="getEditedIds-query-document"/>
							</p:processor>

							<p:processor name="oxf:url-generator">
								<p:input name="config">
									<config>
										<url>oxf:/apps/nomisma/ui/sparql/getSpreadsheets.sparql</url>
										<content-type>text/plain</content-type>
										<encoding>utf-8</encoding>
									</config>
								</p:input>
								<p:output name="data" id="getSpreadsheets-query"/>
							</p:processor>

							<p:processor name="oxf:text-converter">
								<p:input name="data" href="#getSpreadsheets-query"/>
								<p:input name="config">
									<config/>
								</p:input>
								<p:output name="data" id="getSpreadsheets-query-document"/>
							</p:processor>

							<!-- execute SPARQL query to get a list of spreadsheets -->
							<p:processor name="oxf:pipeline">
								<p:input name="data" href="#data"/>
								<p:input name="config" href="../../../models/sparql/getSpreadsheets.xpl"/>
								<p:output name="data" id="spreadsheet-list"/>
							</p:processor>

							<!-- execute SPARQL query to get a sample list of 100 created/edited IDs by the Nomisma editor -->
							<p:processor name="oxf:pipeline">
								<p:input name="data" href="#data"/>
								<p:input name="config" href="../../../models/sparql/getEditedIds.xpl"/>
								<p:output name="data" id="id-list"/>
							</p:processor>

							<!-- aggregate models and serialize into HTML -->
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="id-count" href="#id-count"/>
								<p:input name="id-list" href="#id-list"/>
								<p:input name="getSpreadsheets-query" href="#getSpreadsheets-query-document"/>
								<p:input name="getEditedIds-query" href="#getEditedIds-query-document"/>
								<p:input name="spreadsheet-list" href="#spreadsheet-list"/>
								<p:input name="data" href="aggregate('content', #data, ../../../../config.xml)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/rdf/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="id-count" href="#id-count"/>
								<p:input name="data" href="aggregate('content', #data, ../../../../config.xml)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/rdf/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:when>
			</p:choose>
		</p:when>
		<p:when test="/scheme = 'id'">
			<!-- get ASK query from a text file on disk -->
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/nomisma/ui/sparql/ask.sparql</url>
						<content-type>text/plain</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" id="query"/>
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="query-document"/>
			</p:processor>
			
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="config-xml" href="../../../../config.xml"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
						xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						
						<xsl:variable name="type" select="/rdf:RDF/*[1]/name()"/>

						<xsl:template match="/">
							<type>
								<xsl:attribute name="hasMints" select="doc('input:config-xml')//classes/class[text()=$type]/@mints"/>
								<xsl:attribute name="hasFindspots" select="doc('input:config-xml')//classes/class[text()=$type]/@findspots"/>
								<xsl:attribute name="hasTypes" select="doc('input:config-xml')//classes/class[text()=$type]/@types"/>
								
								<xsl:value-of select="$type"/>
							</type>
						</xsl:template>

					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="type"/>
			</p:processor>

			<!-- ASK whether there are geographic coordinates for mints or findspots in order to generate a conditional for the map -->
			<p:choose href="#type">
				<!-- suppress any class of object for which we do not want to render a map -->
				<p:when test="type/@hasMints = false()">
					<p:processor name="oxf:identity">
						<p:input name="data">
							<sparql xmlns="http://www.w3.org/2005/sparql-results#">
								<head/>
								<boolean>false</boolean>
							</sparql>
						</p:input>
						<p:output name="data" id="hasMints"/>
					</p:processor>
				</p:when>
				<!-- apply alternate SPARQL query to get mints associated with a Hoard -->
				<p:otherwise>
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="query" href="#query-document"/>
						<p:input name="data" href="#type"/>
						<p:input name="config-xml" href=" ../../../../config.xml"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
								xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all">
								<xsl:include href="../../../../ui/xslt/controllers/metamodel-templates.xsl"/>
								<xsl:include href="../../../../ui/xslt/controllers/sparql-metamodel.xsl"/>

								<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
								<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
								<xsl:variable name="type" select="/type"/>

								<xsl:variable name="query" select="doc('input:query')"/>

								<xsl:variable name="statements" as="element()*">
									<xsl:call-template name="nomisma:getMintsStatements">
										<xsl:with-param name="type" select="$type"/>
										<xsl:with-param name="id" select="$id"/>
									</xsl:call-template>
								</xsl:variable>

								<xsl:variable name="statementsSPARQL">
									<xsl:apply-templates select="$statements/*"/>
								</xsl:variable>

								<xsl:variable name="service"
									select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>

								<xsl:template match="/">
									<config>
										<url>
											<xsl:value-of select="$service"/>
										</url>
										<content-type>application/xml</content-type>
										<encoding>utf-8</encoding>
									</config>
								</xsl:template>

							</xsl:stylesheet>
						</p:input>
						<p:output name="data" id="hasMints-url-generator-config"/>
					</p:processor>

					<p:processor name="oxf:url-generator">
						<p:input name="config" href="#hasMints-url-generator-config"/>
						<p:output name="data" id="mint-url-data"/>
					</p:processor>

					<p:processor name="oxf:exception-catcher">
						<p:input name="data" href="#mint-url-data"/>
						<p:output name="data" id="mint-url-data-checked"/>
					</p:processor>

					<!-- Check whether we had an exception -->
					<p:choose href="#mint-url-data-checked">
						<p:when test="/exceptions">
							<!-- Extract the message -->
							<p:processor name="oxf:identity">
								<p:input name="data">
									<sparql xmlns="http://www.w3.org/2005/sparql-results#">
										<head/>
										<boolean>false</boolean>
									</sparql>
								</p:input>
								<p:output name="data" id="hasMints"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<!-- Just return the document -->
							<p:processor name="oxf:identity">
								<p:input name="data" href="#mint-url-data-checked"/>
								<p:output name="data" id="hasMints"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:otherwise>
			</p:choose>

			<p:choose href="#type">
				<!-- suppress any class of object for which we do not want to render a map -->
				<p:when test="type/@hasFindspots = false()">
					<p:processor name="oxf:identity">
						<p:input name="data">
							<sparql xmlns="http://www.w3.org/2005/sparql-results#">
								<head/>
								<boolean>false</boolean>
							</sparql>
						</p:input>
						<p:output name="data" id="hasFindspots"/>
					</p:processor>
				</p:when>
				<!-- execute SPARQL query for other classes of object -->
				<p:otherwise>					
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="query" href="#query-document"/>
						<p:input name="data" href="#type"/>
						<p:input name="config-xml" href=" ../../../../config.xml"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
								xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all">
								<xsl:include href="../../../../ui/xslt/controllers/metamodel-templates.xsl"/>
								<xsl:include href="../../../../ui/xslt/controllers/sparql-metamodel.xsl"/>
								
								<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
								<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
								<xsl:variable name="type" select="/type"/>
								
								<xsl:variable name="query" select="doc('input:query')"/>
								
								<xsl:variable name="statements" as="element()*">
									<xsl:call-template name="nomisma:getFindspotsStatements">
										<xsl:with-param name="type" select="$type"/>
										<xsl:with-param name="id" select="$id"/>
									</xsl:call-template>
								</xsl:variable>
								
								<xsl:variable name="statementsSPARQL">
									<xsl:apply-templates select="$statements/*"/>
								</xsl:variable>
								
								<xsl:variable name="service"
									select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>
								
								<xsl:template match="/">
									<config>
										<url>
											<xsl:value-of select="$service"/>
										</url>
										<content-type>application/xml</content-type>
										<encoding>utf-8</encoding>
									</config>
								</xsl:template>
								
							</xsl:stylesheet>
						</p:input>
						<p:output name="data" id="hasFindspots-url-generator-config"/>
					</p:processor>

					<p:processor name="oxf:url-generator">
						<p:input name="config" href="#hasFindspots-url-generator-config"/>
						<p:output name="data" id="findspot-url-data"/>
					</p:processor>

					<p:processor name="oxf:exception-catcher">
						<p:input name="data" href="#findspot-url-data"/>
						<p:output name="data" id="findspot-url-data-checked"/>
					</p:processor>

					<!-- Check whether we had an exception -->
					<p:choose href="#findspot-url-data-checked">
						<p:when test="/exceptions">
							<!-- Extract the message -->
							<p:processor name="oxf:identity">
								<p:input name="data">
									<sparql xmlns="http://www.w3.org/2005/sparql-results#">
										<head/>
										<boolean>false</boolean>
									</sparql>
								</p:input>
								<p:output name="data" id="hasFindspots"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<!-- Just return the document -->
							<p:processor name="oxf:identity">
								<p:input name="data" href="#findspot-url-data-checked"/>
								<p:output name="data" id="hasFindspots"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:otherwise>
			</p:choose>

			<!-- ASK whether there are coin types associated with the concept -->
			<p:choose href="#type">
				<!-- suppress any class of object for which we do not want to render a map -->
				<p:when test="type/@hasTypes = false()">
					<p:processor name="oxf:identity">
						<p:input name="data">
							<sparql xmlns="http://www.w3.org/2005/sparql-results#">
								<head/>
								<boolean>false</boolean>
							</sparql>
						</p:input>
						<p:output name="data" id="hasTypes"/>
					</p:processor>
				</p:when>
				<!-- execute SPARQL query for other classes of object -->
				<p:otherwise>
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="query" href="#query-document"/>
						<p:input name="data" href="#type"/>
						<p:input name="config-xml" href=" ../../../../config.xml"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
								xmlns:nomisma="http://nomisma.org/" exclude-result-prefixes="#all">
								<xsl:include href="../../../../ui/xslt/controllers/metamodel-templates.xsl"/>
								<xsl:include href="../../../../ui/xslt/controllers/sparql-metamodel.xsl"/>

								<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql_query"/>
								<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
								<xsl:variable name="type" select="/type"/>

								<xsl:variable name="query" select="doc('input:query')"/>

								<xsl:variable name="statements" as="element()*">
									<xsl:call-template name="nomisma:listTypesStatements">
										<xsl:with-param name="type" select="$type"/>
										<xsl:with-param name="id" select="$id"/>
									</xsl:call-template>
								</xsl:variable>

								<xsl:variable name="statementsSPARQL">
									<xsl:apply-templates select="$statements/*"/>
								</xsl:variable>

								<xsl:template match="/">

									<xsl:variable name="service"
										select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, '%STATEMENTS%', $statementsSPARQL)), '&amp;output=xml')"/>

									<config>
										<url>
											<xsl:value-of select="$service"/>
										</url>
										<content-type>application/xml</content-type>
										<encoding>utf-8</encoding>
									</config>
								</xsl:template>

							</xsl:stylesheet>
						</p:input>
						<p:output name="data" id="hasTypes-url-generator-config"/>
					</p:processor>

					<p:processor name="oxf:url-generator">
						<p:input name="config" href="#hasTypes-url-generator-config"/>
						<p:output name="data" id="type-url-data"/>
					</p:processor>

					<p:processor name="oxf:exception-catcher">
						<p:input name="data" href="#type-url-data"/>
						<p:output name="data" id="type-url-data-checked"/>
					</p:processor>

					<!-- Check whether we had an exception -->
					<p:choose href="#type-url-data-checked">
						<p:when test="/exceptions">
							<!-- Extract the message -->
							<p:processor name="oxf:identity">
								<p:input name="data">
									<sparql xmlns="http://www.w3.org/2005/sparql-results#">
										<head/>
										<boolean>false</boolean>
									</sparql>
								</p:input>
								<p:output name="data" id="hasTypes"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<!-- Just return the document -->
							<p:processor name="oxf:identity">
								<p:input name="data" href="#type-url-data-checked"/>
								<p:output name="data" id="hasTypes"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:otherwise>
			</p:choose>

			<!-- aggregate models and serialize into HTML -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #data, ../../../../config.xml, #hasMints, #hasFindspots, #hasTypes)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/rdf/html.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:when>
	</p:choose>
	
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#model"/>
		<p:input name="config" href="../../../controllers/http-headers.xpl"/>
		<p:output name="data" ref="data"/>
	</p:processor>

	<!--<p:processor name="oxf:html-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<version>5.0</version>
				<indent>true</indent>
				<content-type>text/html</content-type>
				<encoding>utf-8</encoding>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>-->
</p:config>
