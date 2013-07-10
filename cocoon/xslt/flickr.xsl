<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

	<xsl:include href="templates.xsl"/>

	<xsl:param name="flickr_api_key"/>
	<xsl:variable name="service" select="concat('http://api.flickr.com/services/rest/?api_key=', $flickr_api_key)"/>
	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml"
			prefix="nm: http://nomisma.org/id/
			dcterms: http://purl.org/dc/terms/
			foaf: http://xmlns.com/foaf/0.1/
			geo:  http://www.w3.org/2003/01/geo/wgs84_pos#
			owl:  http://www.w3.org/2002/07/owl#
			rdfs: http://www.w3.org/2000/01/rdf-schema#
			rdfa: http://www.w3.org/ns/rdfa#
			rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
			skos: http://www.w3.org/2004/02/skos/core#"
			vocab="http://nomisma.org/id/">
			<head>
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/>
				<title>Nomisma Flickr Machine Tags</title>
				<style type="text/css">
					@import url(<xsl:value-of select="concat($display_path, 'style.css')"/>
					);</style>
				<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"/>
			</head>
			<body>
				<xsl:call-template name="header"/>

				<div class="center">
					<h3>Flickr Machine Tags</h3>
					<p>Flickr images may be tagged with <a href="http://www.flickr.com/groups/api/discuss/72157594497877875/">machine tags</a> to aid in computerized organization and aggregation. The
						format for tagging photos for nomisma-defined numismatic concepts is as follows:</p>

					<p>nomisma:CONCEPT=VALUE</p>

					<p>Examples:</p>
					<p>
						<dl>
							<li>
								<b>Authority: Augustus - </b>
								<a href="http://www.flickr.com/search/?q=nomisma:authority=augustus">nomisma:authority=augustus</a>
							</li>
							<li>
								<b>Denomination: Aureus - </b>
								<a href="http://www.flickr.com/search/?q=nomisma:denomination=aureus">nomisma:denomination=aureus</a>
							</li>
							<li>
								<b>Mint: Rome - </b>
								<a href="http://www.flickr.com/search/?q=nomisma:mint=rome">nomisma:mint=rome</a>
							</li>
							<li>
								<b>Coin Type: RIC Augustus 1a - </b>
								<a href="http://www.flickr.com/search/?q=nomisma:type_series_item=ric.1(2).aug.1a">nomisma:type_series_item=ric.1(2).aug.1a</a>
							</li>
						</dl>
					</p>

					<p><a href="http://www.flickr.com/photos/tags/nomisma:*">See all images</a> with nomisma machine tags.</p>
				</div>

				<div class="center">
					<h3>Examples</h3>
					<xsl:for-each select="document(concat($service, '&amp;method=flickr.photos.search&amp;per_page=12&amp;machine_tags=nomisma:'))//photo">
						<div class="flickr_thumbnail">
							<a href="http://www.flickr.com/photos/{@owner}/{@id}" title="{@title}">
								<img src="{document(concat($service, '&amp;method=flickr.photos.getSizes&amp;photo_id=', @id))//size[@label='Thumbnail']/@source}" alt="{@title}"/>
							</a>
						</div>
					</xsl:for-each>
				</div>


				<!-- footer -->
				<xsl:call-template name="footer"/>

			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
