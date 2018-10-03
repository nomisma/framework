#!/usr/bin/env python
import sys
from rdflib import Graph, plugin
from rdflib.serializer import Serializer

#get argument
id = sys.argv[1]
scheme = sys.argv[2]
file = "file:///usr/local/projects/nomisma-data/" + scheme + "/" + id + ".rdf"

graph = Graph()

graph.parse(file, format='application/rdf+xml')
#print len(graph)
print(graph.serialize(format='text/turtle'))
