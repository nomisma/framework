#!/usr/bin/env python
import sys
from rdflib import Graph, plugin
from rdflib.serializer import Serializer

id = sys.argv[1]
scheme = sys.argv[2]
format = sys.argv[3]
file = "file:///usr/local/projects/nomisma-data/" + scheme + "/" + id + ".rdf"

graph = Graph()

graph.parse(file, format='application/rdf+xml')

if format == 'jsonld':
    print(graph.serialize(format='json-ld', indent=4))
elif format == 'ttl':
    print(graph.serialize(format='text/turtle'))