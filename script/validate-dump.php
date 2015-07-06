<?php
require 'vendor/autoload.php';

$graph = EasyRdf_Graph::newAndLoad("http://localhost:8080/orbeon/nomisma/id/rome.rdf");
$objects = $graph->resources();
foreach ($objects as $object){
	var_dump($object->types());
}