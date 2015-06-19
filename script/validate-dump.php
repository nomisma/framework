<?php
require 'vendor/autoload.php';

$rdf = new EasyRdf_Graph("http://localhost:8080/orbeon/nomisma/id/rome.rdf");
$rdf->load();
echo "test\n";