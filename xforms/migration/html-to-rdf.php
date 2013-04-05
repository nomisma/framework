<?php 
	/* Author: Ethan Gruber, American Numismatic Society
	 * Function: Generate Solr doc from nomisma id .txt file and post it
	 */

	$current_date = date("Y-m-d");
	$id_dir = '/home/komet/ans_migration/nomisma/id/';	
	$dir = opendir($id_dir);

	//cycle through the 'id' folder, populating array with txt files
	$files = array();
	while (false !== ($file = readdir($dir))) {
		$files[] = $file;
	}
	closedir($dir);
    
	//execute transformation and indexing process on array
	if(count($files) > 0){
		foreach ($files as $file){			
			if (file_exists($id_dir . $file)){					
				$doc = new DOMDocument();
				$doc->load($id_dir . $file);
				$xpath = new DOMXpath($doc);

				$divs = $xpath->query('/div');
				
				$idAttr = '';
				$typeofAttr = '';
				foreach ($divs as $div){
					$idAttr = $div->getAttribute('about');
					$typeofAttr = $div->getAttribute('typeof');
				}
				
				$id = str_replace('[', '', str_replace(']', '', str_replace('nm:', '', $idAttr)));
				$typeof = str_replace('nm:', '', $typeofAttr);
				
				//generate XML, ignore hoard, type_series_item, numismatic_term
				if ($typeof != 'hoard' && $typeof != 'type_series_item' && $typeof != 'numismatic_term'){
					$prefLabels = $xpath->query('//div[@property="skos:prefLabel"]');
					$altLabels = $xpath->query('//span[@property="skos:altLabel"]');
					$definitions = $xpath->query('//div[@property="skos:definition"]');
					$positions = $xpath->query('//*[@property="gml:pos"]');
					$related_links = $xpath->query('//*[contains(@rel,"skos:related")]');
					$latlongsources = $xpath->query('//*[contains(@rel,"nm:latlongsource")]');
					
					$xml = '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
					$xml .= '<rdf:RDF xmlns:nm="http://nomisma.org/id/" xmlns:ov="http://open.vocab.org/terms/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
					xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:nuds="http://nomisma.org/id/nuds" xmlns:foaf="http://xmlns.com/foaf/0.1/"
					xmlns:gml="http://www.opengis.net/gml/">';		
					$xml .= "\n\t" . '<skos:Concept rdf:about="http://nomisma.org/id/' . $id . '">';
					$xml .= "\n\t\t" . '<skos:broader rdf:about="http://nomisma.org/id/' . $typeof . '"/>';
					foreach ($prefLabels as $prefLabel){
						$lang = (strlen($prefLabel->getAttribute('xml:lang')) > 0) ? $prefLabel->getAttribute('xml:lang') : 'en';
						$xml .= "\n\t\t" . '<skos:prefLabel xml:lang="' . $lang . '">' . $prefLabel->nodeValue . '</skos:prefLabel>';
					}
					foreach ($altLabels as $altLabel){
						$lang = (strlen($altLabel->getAttribute('xml:lang')) > 0) ? $altLabel->getAttribute('xml:lang') : 'en';
						$xml .= "\n\t\t" . '<skos:altLabel xml:lang="' . $lang . '">' . $altLabel->nodeValue . '</skos:altLabel>';
					}	
					foreach ($definitions as $definition){
						$lang = (strlen($definition->getAttribute('xml:lang')) > 0) ? $definition->getAttribute('xml:lang') : 'en';
						$xml .= "\n\t\t" . '<skos:definition xml:lang="' . $lang . '">' . $definition->nodeValue . '</skos:definition>';
					}
					foreach ($positions as $position){
						$xml .= "\n\t\t" . '<gml:pos>' . $position->nodeValue . '</gml:pos>';
					}
					foreach ($related_links as $related){
						$lang = (strlen($related->getAttribute('xml:lang')) > 0) ? $related->getAttribute('xml:lang') : 'en';
						$xml .= "\n\t\t" . '<skos:related rdf:resource="' . str_replace('&', '&amp;', $related->getAttribute('href')) . '" xml:lang="' . $lang . '"/>';					
					}	
					foreach ($latlongsources as $source){
						$lang = (strlen($source->getAttribute('xml:lang')) > 0) ? $source->getAttribute('xml:lang') : 'en';
						$xml .= "\n\t\t" . '<nm:latlongsource rdf:resource="' . str_replace('&', '&amp;', $source->getAttribute('href')) . '" xml:lang="' . $lang . '"/>';			
					}		
					$xml .= "\n\t</skos:Concept>\n</rdf:RDF>\n";		
					echo 'Writing ' . $file . "\n";
					//write file to /tmp
					$fileName = $id_dir . str_replace('.txt', '', $file) . '.xml';
					$writeFile = fopen($fileName, 'w') or die("can't open file");
					fwrite($writeFile, $xml);
				}				
			}		
		}
	}
?>
