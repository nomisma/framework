#!/usr/bin/env python3

"""
Author: Ethan Gruber
Date: September 2026
Function: Generate RDF/XML dump by aggregating triples from directories and then output TTL and JSON-LD
"""

import sys, glob
import xml.etree.ElementTree as ET
from rdflib import Graph, plugin
from rdflib.serializer import Serializer

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
"un": "http://www.owl-ontologies.com/Ontology1181490123.owl#",
"void": "http://rdfs.org/ns/void#",
"wordnet": "http://ontologi.es/WordNet/class/",
"xsd": "http://www.w3.org/2001/XMLSchema#"}

def main():     
    print("Combining all RDF/XML files")
    
    #aggregate Nomisma directories
    rdf_files = glob.glob("/usr/local/projects/nomisma-data/editor/*.rdf")  + glob.glob("/usr/local/projects/nomisma-data/symbol/*.rdf") + glob.glob("/usr/local/projects/nomisma-data/id/*.rdf")
    
    rdf_files.sort()
    #print(rdf_files)
    
    ET.register_namespace('rdf',"http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    ET.register_namespace('foaf',"http://xmlns.com/foaf/0.1/")
    ET.register_namespace("bio", "http://purl.org/vocab/bio/0.1/")
    ET.register_namespace("crm", "http://www.cidoc-crm.org/cidoc-crm/")
    ET.register_namespace("crmarchaeo", "http://www.cidoc-crm.org/cidoc-crm/CRMarchaeo/")
    ET.register_namespace("crmdig", "http://www.ics.forth.gr/isl/CRMdig/")
    ET.register_namespace("crmgeo", "http://www.ics.forth.gr/isl/CRMgeo/")
    ET.register_namespace("crmsci", "http://www.ics.forth.gr/isl/CRMsci/")
    ET.register_namespace("dcterms", "http://purl.org/dc/terms/")
    ET.register_namespace("dcmitype", "http://purl.org/dc/dcmitype/")
    ET.register_namespace("geo", "http://www.w3.org/2003/01/geo/wgs84_pos#")
    ET.register_namespace("nm", "http://nomisma.org/id/")
    ET.register_namespace("nmo", "http://nomisma.org/ontology#")
    ET.register_namespace("org", "http://www.w3.org/ns/org#")
    ET.register_namespace("osgeo", "http://data.ordnancesurvey.co.uk/ontology/geometry/")
    ET.register_namespace("prov", "http://www.w3.org/ns/prov#")
    ET.register_namespace("rdac", "http://www.rdaregistry.info/Elements/c/")
    ET.register_namespace("rdfs", "http://www.w3.org/2000/01/rdf-schema#")
    ET.register_namespace("skos", "http://www.w3.org/2004/02/skos/core#")
    ET.register_namespace("un", "http://www.owl-ontologies.com/Ontology118190123.owl#") 
    ET.register_namespace("wordnet", "http://ontologi.es/WordNet/class/")
    ET.register_namespace("xsd", "http://www.w3.org/2001/XMLSchema#")
    
    
    combined = ET.Element('{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF')
    ET.indent(combined, space="\t", level=0)
    
    for rdf_file in rdf_files:
        data = ET.parse(rdf_file).getroot()
        
        for node in data.findall('./*'):
            combined.append(node)

    rdf_data = ET.tostring(combined, encoding='utf-8')
    
    tree = ET.ElementTree(combined)
    tree.write("/usr/local/projects/nomisma/dump/nomisma.org.rdf",
           encoding='utf-8',
           xml_declaration=True)
    
    print("Wrote RDF/XML")
    
    #generate TTL and JSON-LD
    print("Parsing RDF/XML")
    graph = Graph()
    graph.parse("/usr/local/projects/nomisma/dump/nomisma.org.rdf", format='application/rdf+xml')
    print("Parsing finished")
    
    print("Serializing to JSON-LD")
    graph.serialize(destination="file:///usr/local/projects/nomisma/dump/nomisma.org.jsonld", context=context, format='json-ld', indent=4)
    
    print("Serializing to TTL")
    graph.serialize(destination="file:///usr/local/projects/nomisma/dump/nomisma.org.ttl", format='text/turtle')
    
    

if __name__=="__main__":
    main()