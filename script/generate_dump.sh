#Generate dumps
cd /usr/local/projects/nomisma
echo "Generating RDF/XML."
java -jar script/saxon9.jar -s:config.xml -xsl:ui/xslt/apis/aggregate-all.xsl -o:dump/nomisma.org.rdf
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
