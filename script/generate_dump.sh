#write xhtml+rdfa file
cd /usr/local/projects/nomisma
echo "Generating RDF/XML."
java -jar script/saxon9.jar -s:config.xml -xsl:ui/xslt/apis/aggregate-all.xsl > dump/nomisma.org.rdf
echo "Done."
#use wrapper to generate TTL, N-triples, and RDF/JSON
echo "Generating N-Triples."
rapper -i rdfxml -o ntriples dump/nomisma.org.rdf > dump/nomisma.org.nt
echo "Done."
echo "Generating Turtle."
rapper -i rdfxml -o turtle dump/nomisma.org.rdf > dump/nomisma.org.ttl
echo "Done."

#create Pelagios RDF dump
#echo "Generating Pelagios RDF."
#curl http://localhost:8080/cocoon/nomisma/get_pelagios > cocoon/dump/pelagios.rdf
#echo "Done."
echo "Process complete."
