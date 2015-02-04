#!/bin/sh
OUTPUT="$(date +%Y-%m-%dT%T) - Automatic Update"
cd /usr/local/projects/nomisma-data
#add new files
git add *.rdf
#commit
git commit -am "$OUTPUT"
git push
echo "Done."
