#write xhtml+rdfa file
echo "Generating XHTML+RDFa."
XHTML=../cocoon/dump/nomisma.org.xml
cat ../cocoon/dump/xhtml-header.txt > $XHTML
for i in `ls /usr/local/projects/nomisma-ids/id/*.txt`; do cat $i >> $XHTML; done;
echo '</body></html>' >> $XHTML
echo "Done."
#write RDF/XML file
mkdir tmp
echo "Generating RDF/XML."
java -jar saxon9.jar -xsl:../cocoon/xslt/display/rdf.xsl -s:/usr/local/projects/nomisma-ids/id -o:tmp
echo "Done."
RDF=../cocoon/dump/nomisma.org.rdf
echo "Compiling Dump."
echo '<?xml version="1.0" encoding="UTF-8"?><rdf:RDF xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:nm="http://nomisma.org/id/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">' > $RDF
for i in `ls tmp/*.xml`; do sed '1,10 d' $i | sed 's/<\/rdf:RDF>//g'  >> $RDF; done
echo '</rdf:RDF>' >> $RDF
rm -rf tmp/
echo "Done."

#use wrapper to generate TTL, N-triples, and RDF/JSON
echo "Generating N-Triples."
rapper -i rdfxml -o ntriples ../cocoon/dump/nomisma.org.rdf > ../cocoon/dump/nomisma.org.nt
echo "Done."
echo "Generating Turtle."
rapper -i rdfxml -o turtle ../cocoon/dump/nomisma.org.rdf > ../cocoon/dump/nomisma.org.ttl
echo "Done."
echo "Generating RDF/JSON."
rapper -i rdfxml -o json-triples ../cocoon/dump/nomisma.org.rdf > ../cocoon/dump/nomisma.org.rj
echo "Done."
echo "Process complete."
