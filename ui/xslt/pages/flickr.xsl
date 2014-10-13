<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:variable name="display_path">./</xsl:variable>
	
	<xsl:param name="flickr_api_key"/>
	<xsl:variable name="service" select="concat('http://api.flickr.com/services/rest/?api_key=', $flickr_api_key)"/>
	
	<xsl:template match="/">
		<html lang="en">
			<head>
				<title>nomisma.org: Flickr Machine Tags</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script type="text/javascript" src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
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
					<div>
						<h1>Flickr Machine Tags</h1>
						<p>Flickr images may be tagged with <a href="http://www.flickr.com/groups/api/discuss/72157594497877875/">machine tags</a> to aid in computerized organization and aggregation. The
							format for tagging photos for nomisma-defined numismatic concepts is as follows:</p>
						
						<p>nomisma:CONCEPT=VALUE</p>
						
						<p>Examples:</p>
						<ul>
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
						</ul>
						
						<p><a href="http://www.flickr.com/photos/tags/nomisma:*">See all images</a> with nomisma machine tags.</p>
					</div>
					
					<!--<div>
						<h3>Examples</h3>
						<xsl:for-each select="document(concat($service, '&amp;method=flickr.photos.search&amp;per_page=12&amp;machine_tags=nomisma:'))//photo">
							<div class="flickr_thumbnail">
								<a href="http://www.flickr.com/photos/{@owner}/{@id}" title="{@title}">
									<img src="{document(concat($service, '&amp;method=flickr.photos.getSizes&amp;photo_id=', @id))//size[@label='Thumbnail']/@source}" alt="{@title}"/>
								</a>
							</div>
						</xsl:for-each>
					</div>-->
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
