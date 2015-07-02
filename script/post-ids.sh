#!/bin/sh
#REQUIRED: files.list file with the filename (with .rdf extension) on each line
FUSEKI=/usr/local/projects/fuseki
IDS=/usr/local/projects/nomisma-data/id

for i in `cat files.list`; do
echo "Posting $i"
cd $FUSEKI
./s-post http://localhost:3030/nomisma/data default $IDS/$i;
done
