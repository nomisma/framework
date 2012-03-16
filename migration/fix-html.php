<?php 
	/* Author: Ethan Gruber, American Numismatic Society
	 * Function: Read XHTML+RDFa fragments and reprocess them, removing some visual labels
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
				$doc = new DOMDocument('1.0', 'UTF-8');
				$doc->load($id_dir . $file);
				$xpath = new DOMXpath($doc);

				$divs = $xpath->query('/div');
				
				$idAttr = '';
				$typeofAttr = '';
				foreach ($divs as $div){
					$id = $div->getAttribute('about');
					$typeof = $div->getAttribute('typeof');
				}
				if ($typeof == 'nm:hoard'){
					$root = $doc->firstChild;
					
					//create <div property="skos:prefLabel" xml:lang="en"/>
					$labelNode = $doc->createElement('div', preg_replace("/\[nm:(.*)\]/", "$1", $id));
					
					//create <div property="skos:definition" xml:lang="en"/>
					$definitionNode = $doc->createElement('div', preg_replace("/\[nm:(.*)\]/", "$1", $id) . ' from Inventory of Greek Coin Hoards');
					
					//create attributes for prefLabel
					$labelProperty = $doc->createAttribute('property');
					$labelLang = $doc->createAttribute('xml:lang');
					$labelProperty->value = 'skos:prefLabel';
					$labelLang->value = 'en';
					
					//insert attributes into prefLabel
					$insertLabelProperty = $labelNode->appendChild($labelProperty);
					$insertLabelLang = $labelNode->appendChild($labelLang);
					
					//insert prefLabel
					$insertLabel = $root->appendChild($labelNode);
					
					//create attributes for definition
					$definitionProperty = $doc->createAttribute('property');
					$definitionLang = $doc->createAttribute('xml:lang');
					$definitionProperty->value = 'skos:definition';
					$definitionLang->value = 'en';
					
					//insert attributes into definition
					$insertDefinitionProperty = $definitionNode->appendChild($definitionProperty);
					$insertDefinitionLang = $definitionNode->appendChild($definitionLang);
					
					//insert definition
					$insertDefinition = $root->appendChild($definitionNode);
					
					//create attributes for root node
					$rootXmlns = $doc->createAttribute('xmlns');
					$rootPrefix = $doc->createAttribute('prefix');
					$rootXmlns->value = 'http://www.w3.org/1999/xhtml';
					$rootPrefix->value = '=nm: http://nomisma.org/id/ dcterms: http://purl.org/dc/terms/ rdfs: http://www.w3.org/2000/01/rdf-schema# foaf: http://xmlns.com/foaf/0.1/ rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns# owl:  http://www.w3.org/2002/07/owl# rdfs: http://www.w3.org/2000/01/rdf-schema# rdfa: http://www.w3.org/ns/rdfa#';
					
					//insert attributes into root
					$insertRootXmlns = $root->appendChild($rootXmlns);
					$insertRootPrefix = $root->appendChild($rootPrefix);
					
					//echo $doc->saveXML();	
					echo 'Writing ' . $file . "\n";				
					$doc->save($id_dir . str_replace('.txt', '.xml', $file));
				}
				//generate XML, ignore hoard, type_series_item, numismatic_term
				elseif ($typeof != 'nm:hoard' && $typeof != 'nm:type_series_item'){
					$prefLabels = $xpath->query('//div[@property="skos:prefLabel"]');
					$altLabels = $xpath->query('//span[@property="skos:altLabel"]');
					$definitions = $xpath->query('//div[@property="skos:definition"]');
					$positions = $xpath->query('//*[@property="gml:pos"]');
					$related_links = $xpath->query('//*[contains(@rel,"skos:related")]');
					$latlongsources = $xpath->query('//*[contains(@rel,"nm:latlongsource")]');
					$broaders = $xpath->query('//*[contains(@rel,"skos:broader")]');
					
					
					$xml = '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
					$xml .= '<div xmlns="http://www.w3.org/1999/xhtml"
    prefix="=nm: http://nomisma.org/id/
    dcterms: http://purl.org/dc/terms/
    rdfs: http://www.w3.org/2000/01/rdf-schema# 
    foaf: http://xmlns.com/foaf/0.1/
    rdf:  http://www.w3.org/1999/02/22-rdf-syntax-ns#
    owl:  http://www.w3.org/2002/07/owl#
    rdfs: http://www.w3.org/2000/01/rdf-schema#
    rdfa: http://www.w3.org/ns/rdfa#
    " about="' . $id . '" typeof="' . $typeof . '">';
					foreach ($prefLabels as $prefLabel){
						$lang = (strlen($prefLabel->getAttribute('xml:lang')) > 0) ? $prefLabel->getAttribute('xml:lang') : 'en';
						$xml .= "\n\t" . '<div property="skos:prefLabel" xml:lang="' . $lang . '">' . $prefLabel->nodeValue . '</div>';
					}
					foreach ($altLabels as $altLabel){
						$lang = (strlen($altLabel->getAttribute('xml:lang')) > 0) ? $altLabel->getAttribute('xml:lang') : 'en';
						$xml .= "\n\t" . '<div property="skos:altLabel" xml:lang="' . $lang . '">' . $altLabel->nodeValue . '</div>';
					}	
					foreach ($definitions as $definition){
						$lang = (strlen($definition->getAttribute('xml:lang')) > 0) ? $definition->getAttribute('xml:lang') : 'en';
						$xml .= "\n\t" . '<div property="skos:definition" xml:lang="' . $lang . '">' . $definition->nodeValue . '</div>';
					}
					foreach ($positions as $position){
						$xml .= "\n\t" . '<div property="gml:pos">' . $position->nodeValue . '</div>';
					}
					foreach ($related_links as $related){
						$lang = (strlen($related->getAttribute('xml:lang')) > 0) ? $related->getAttribute('xml:lang') : 'en';
						$xml .= "\n\t" . '<div><a rel="skos:related" href="' . str_replace('&', '&amp;', $related->getAttribute('href')) . '" xml:lang="' . $lang . '"/></div>';					
					}	 
					foreach ($broaders as $broader){
						$xml .= "\n\t" . '<div><a rel="skos:broader" href="http://nomisma.org/id/' . $broader->getAttribute('href') . '">' . $broader->getAttribute('href') . '</a></div>';					
					}	
					foreach ($latlongsources as $source){
						$lang = (strlen($source->getAttribute('xml:lang')) > 0) ? $source->getAttribute('xml:lang') : 'en';
						$xml .= "\n\t\t" . '<div><a rel="nm:latlongsource" href="' . str_replace('&', '&amp;', $source->getAttribute('href')) . '" xml:lang="' . $lang . '"/></div>';				
					}		
					$xml .= "\n</div>\n";		
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