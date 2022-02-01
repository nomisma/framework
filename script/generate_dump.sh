#Generate dumps
cd /usr/local/projects/nomisma
echo "Generating RDF/XML."
java -jar script/saxon9.jar -s:config.xml -xsl:ui/xslt/apis/aggregate-all.xsl -o:dump/nomisma.org.rdf
echo "Done."
#use wrapper to generate TTL
echo "Generating Turtle."
python3 script/serialize-rdfdump.py ttl
echo "Done."
#use saxon to create JSON-LD
echo "Generating JSON-LD."
python3 script/serialize-rdfdump.py json
echo "Done."
echo "Updating permissions."
chmod a+r dump/nomisma.org.*
echo "Process complete."
