#!/usr/bin/env python3
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

context = {"bio": "http://purl.org/vocab/bio/0.1/",
"crm": "http://www.cidoc-crm.org/cidoc-crm/",
"crmarchaeo": "http://www.cidoc-crm.org/cidoc-crm/CRMarchaeo/",
"crmdig": "http://www.ics.forth.gr/isl/CRMdig/",
"crmgeo": "http://www.ics.forth.gr/isl/CRMgeo/",
"crmsci": "http://www.ics.forth.gr/isl/CRMsci/",
"dcterms": "http://purl.org/dc/terms/",
"dcmitype": "http://purl.org/dc/dcmitype/",
"foaf": "http://xmlns.com/foaf/0.1/",
"geo": "http://www.w3.org/2003/01/geo/wgs84_pos#",
"nm": "http://nomisma.org/id/",
"nmo": "http://nomisma.org/ontology#",
"org": "http://www.w3.org/ns/org#",
"osgeo": "http://data.ordnancesurvey.co.uk/ontology/geometry/",
"prov": "http://www.w3.org/ns/prov#",
"rdac": "http://www.rdaregistry.info/Elements/c/",
"rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
"rdfs": "http://www.w3.org/2000/01/rdf-schema#",
"sd": "http://www.w3.org/TR/sparql11-service-description/",
"skos": "http://www.w3.org/2004/02/skos/core#",
"spatial": "http://jena.apache.org/spatial#",
"un": "http://www.owl-ontologies.com/Ontology1181490123.owl#",
"void": "http://rdfs.org/ns/void#",
"wordnet": "http://ontologi.es/WordNet/class/",
"xsd": "http://www.w3.org/2001/XMLSchema#"}

#conditional to handle alternate serializations
if format == 'json':
    print("Serializing to JSON-LD")
    graph.serialize(destination="file:///usr/local/projects/nomisma/dump/nomisma.org.jsonld", context=context, format='json-ld', indent=4)
elif format == 'ttl':
    print("Serializing to TTL")
    graph.serialize(destination="file:///usr/local/projects/nomisma/dump/nomisma.org.ttl", format='text/turtle')
else: 
    print("Invalid format\n")
