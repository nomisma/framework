#!/usr/bin/env python
import sys
from rdflib import Graph, plugin
from rdflib.serializer import Serializer

#get argument
format = sys.argv[1]
inFile = "file:///usr/local/projects/nomisma/dump/nomisma.org.rdf"

graph = Graph()

print("Parsing RDF/XML")
graph.parse(inFile, format='application/rdf+xml')
print("Parsing finished")

#conditional to handle alternate serializations
if format == 'json':
    print("Serializing to JSON-LD")
    graph.serialize(destination="file:///usr/local/projects/nomisma/dump/nomisma.org.jsonld", format='json-ld', indent=4)
elif format == 'ttl':
    print("Serializing to TTL")
    graph.serialize(destination="file:///usr/local/projects/nomisma/dump/nomisma.org.ttl", format='text/turtle')
else: 
    print("Invalid format\n")