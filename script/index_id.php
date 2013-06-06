<?php 
	/* Generate Solr doc from nomisma id (version 2.0 -- April 2012) .xml file and post it */

	$current_date = date("Y-m-d");
	$id_dir = '/usr/local/projects/nomisma-ids/id';	
	$dir = opendir($id_dir);

	//cycle through the 'id' folder, populating array with txt files
	$files = array();
	while (false !== ($file = readdir($dir))) {
		if (strstr($file, '.txt')) {
			/* if the file has been modified on the current date, add it to array to be processed 
			 * the intent is that the collection has already been processed once and that 
			 * this script will be run nightly in cron shortly before midnight 
			 */
			/*if (date("Y-m-d") == date("Y-m-d", filemtime($id_dir . '/' . $file))){
				$files[] = $file;
			}*/
			/* Uncomment the line below and comment out the conditional above to process the collection fresh*/
			$files[] = $file;
			 

		}
	}
	closedir($dir);
    
	//execute transformation and indexing process on array
	if(count($files) > 0){
		$xml = '<add>';
		foreach ($files as $file){
			if (file_exists($id_dir . '/' . $file)){
				$id_string = '';
				$type_array = array();
				
				$xml .= "<doc>";
				$doc = new DOMDocument();
				$doc->load($id_dir . '/' . $file);
				$xpath = new DOMXpath($doc);

				$ids = $xpath->query('/*[local-name()="div"]/@about');
				//insert ids into array (should be one)
				foreach ($ids as $id){
					$id_string = $id->nodeValue;
				}

				$types = $xpath->query('/*[local-name()="div"]/@typeof');		
				//create an array of the @typeof attribute, each token separated by a whitespace						
				foreach ($types as $type){
					$type_array = explode(' ', $type->nodeValue);
				}
				
				$prefLabels = $xpath->query('//*[local-name()="div"][@property="skos:prefLabel"]');
				$altLabels = $xpath->query('//*[local-name()="div"][@property="skos:altLabel"]');
				$definitions = $xpath->query('//*[local-name()="div"][@property="skos:definition"][@xml:lang="en"]');
				//$positions = $xpath->query('//*[@property="gml:pos"]');
				$related_links = $xpath->query('//*[local-name()="div"][@property="skos:related"]/@resource');
				$nodes = $xpath->query('//*[local-name()="div"][@property="skos:altLabel" or @property="skos:prefLabel" or @property="skos:definition"]');

				//generate XML
				
				$xml .= "\n\t" . '<field name="id">' . $id_string . '</field>';
				
				foreach ($type_array as $type_string){
					$xml .= "\n\t" . '<field name="typeof">' . $type_string . '</field>';
				}		
				foreach ($prefLabels as $prefLabel){
					if ($prefLabel->getAttribute('xml:lang') == 'en'){
							$xml .= "\n\t" . '<field name="prefLabel">' . $prefLabel->nodeValue . '</field>';
					} else {
						$xml .= "\n\t" . '<field name="altLabel">' . $prefLabel->nodeValue . '</field>';
					}
				}
				foreach ($altLabels as $altLabel){
					$xml .= "\n\t" . '<field name="altLabel">' . $altLabel->nodeValue . '</field>';
				}	
				foreach ($definitions as $definition){
					$xml .= "\n\t" . '<field name="definition">' . $definition->nodeValue . '</field>';
				}
				/*foreach ($positions as $position){
					$xml .= "\n\t" . '<field name="location">' . $position->nodeValue . '</field>';
				}*/
				foreach ($related_links as $related){
					if (strstr($related->nodeValue, 'pleiades')){
						$xml .= "\n\t" . '<field name="pleiades_uri">' . $related->nodeValue . '</field>';
					}       
				} 
				//timestamp
				$xml .= "\n\t" . '<field name="timestamp">' . date(DATE_ATOM) . 'Z</field>';
				
				//fulltext
				$xml .= "\n\t" . '<field name="fulltext">';
				$xml .= $id_string . ' ';
				foreach ($nodes as $node){
					$xml .= $node->nodeValue . ' ';
				}
				$xml .= '</field>';
				
				$xml .= "\n</doc>\n";
				echo 'Posting ' . $file . "\n";
			}
		}
		$xml .= '</add>';
		//echo $xml;
		//post to Solr
		$postToSolr=curl_init();
		curl_setopt($postToSolr,CURLOPT_URL,'http://localhost:8080/solr/nomisma/update/');
		curl_setopt($postToSolr,CURLOPT_POST,1);				
		curl_setopt($postToSolr,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
		curl_setopt($postToSolr,CURLOPT_POSTFIELDS, $xml);				

		$solrResponse = curl_exec($postToSolr);
		echo $solrResponse;
		curl_close($postToSolr);

		$commitToSolr=curl_init();
		curl_setopt($commitToSolr,CURLOPT_URL,'http://localhost:8080/solr/nomisma/update/');
		curl_setopt($commitToSolr,CURLOPT_POST,1);				
		curl_setopt($commitToSolr,CURLOPT_HTTPHEADER, array("Content-Type: text/xml; charset=utf-8"));
		curl_setopt($commitToSolr,CURLOPT_POSTFIELDS, '<commit/>');

		$solrResponse = curl_exec($commitToSolr);
		echo $solrResponse;
		curl_close($commitToSolr);
	}
?>