#Generate dumps
cd /usr/local/projects/nomisma
echo "Generating RDF/XML."
java -jar /var/lib/tomcat7/webapps/orbeon/WEB-INF/orbeon-cli.jar -r /var/lib/tomcat7/webapps/orbeon/WEB-INF/resources oxf:/apps/nomisma/xpl/controllers/generate-rdfxml.xpl
echo "Done."
#use wrapper to generate TTL
echo "Generating Turtle."
rapper -i rdfxml -o turtle dump/nomisma.org.rdf > dump/nomisma.org.ttl
echo "Done."
#use saxon to create JSON-LD
echo "Generating JSON-LD."
java -jar script/saxon9.jar -s:dump/nomisma.org.rdf -xsl:ui/xslt/serializations/rdf/json-ld.xsl -o:dump/nomisma.org.jsonld
echo "Done."
echo "Process complete."
