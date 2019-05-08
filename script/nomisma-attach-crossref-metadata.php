<?php 
 /**************
 * AUTHOR: Ethan Gruber
 * DATE: May 2019
 * FUNCTION: Accept URL parameters for Crossref username, password, and file URL for multipart/form-data
 * REQUIRED LIBRARIES: php7, php7-curl, php7-cgi
 * LICENSE, MORE INFO: 
 **************/
 
//set output header
header('Content-Type: application/xml');

//set the environment
$env = 'dev';

//load XML
$crossrefConfig = '/usr/local/projects/nomisma/crossref-config.xml';

if (file_exists($crossrefConfig)) {
	$xml = simplexml_load_file($crossrefConfig);
	//the line below is for passing request parameters from the command line.
	//parse_str(implode('&', array_slice($argv, 1)), $_GET);
	$username = $xml->username;
	$password = $xml->password;
	$file = $_GET['file'];
	
	//set necessary curl variables
	if ($env == 'dev'){
		$url = "https://test.crossref.org/servlet/deposit";
	} else if ($env = 'prod') {
		$url = "https://doi.crossref.org/servlet/deposit";
	}
	
	$curl = "curl -H 'User-Agent: Nomisma.org/XForms' -F operation=doMDUpload -F login_id={$username} -F login_passwd={$password} -F fname=@/tmp/{$file} {$url}";
	
	//execute as command line since php5-curl does not work correctly
	$response =  exec($curl);
	
	//digest the plain-text or html response from Crossref
	if (strpos($response, 'html') !== FALSE){
		http_response_code(200);
		//echo $response;
		echo "<response>ok</response>";
	} else {
		http_response_code(500);
		//echo $response;
		echo "<response>error</response>";
	}
	
} else {
	exit('Failed to open test.xml.');
}

?>