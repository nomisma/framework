#!/bin/sh
#run as root: changing permissions before committing requires it
OUTPUT="$(date +%Y-%m-%dT%T) - Automatic Update"
cd /usr/local/projects/nomisma-data

#change permissions so that all IDs have the same standardized permissions
sudo chmod -R a+r id/
sudo chmod -R g+w id/
sudo chmod -R a+r symbol/
sudo chmod -R g+w symbol/

#add new files
git add editor/*.rdf
git add id/*.rdf
git add symbol/*.rdf

#commit
git commit -am "$OUTPUT"
git push
echo "Done."
