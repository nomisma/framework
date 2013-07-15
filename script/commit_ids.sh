#!/bin/sh
OUTPUT="$(date +%Y-%m-%dT%T) - Automatic Update"
cd /usr/local/projects/nomisma-ids
git commit -am "$OUTPUT"
git push
echo "Done."
