#!/usr/bin/env python3

"""
Author: Ethan Gruber
Date: September 2026
Function: Linked Art JSON-LD representation of Nomisma concepts
"""

import sys, json, argparse
from shapely.geometry import shape
from rdflib import Graph, URIRef, Namespace
from rdflib.namespace import RDF, XSD, SKOS, RDFS, DCTERMS, FOAF, ORG

CRM = Namespace('http://www.cidoc-crm.org/cidoc-crm/')
NMO = Namespace('http://nomisma.org/ontology#')
GEO = Namespace("http://www.w3.org/2003/01/geo/wgs84_pos#")
WORDNET = Namespace("http://ontologi.es/WordNet/class/")
RDAC = Namespace("http://www.rdaregistry.info/Elements/c/")
OSGEO = Namespace("http://data.ordnancesurvey.co.uk/ontology/geometry/")

def main():    
    
    response = []
    
    print("Parsing RDF/XML")
    g = Graph()
    
    g.bind("rdf", RDF)
    g.bind("rdfs", RDFS)
    g.bind("skos", SKOS)
    g.bind("dcterms", DCTERMS)
    g.bind("foaf", FOAF)
    g.bind("org", ORG)
    g.bind("xsd", XSD)
    g.bind("crm", CRM)
    g.bind("nmo", NMO)
    g.bind("geo", GEO)
    g.bind("osgeo", OSGEO)
    g.bind("wordnet", WORDNET)
    g.bind("rdac", RDAC)
    
    g.parse("/usr/local/projects/nomisma-data/id/rome.rdf", format='application/rdf+xml')
    print("Parsing finished")
    
    for concept in g.subjects(RDF.type, SKOS.Concept):
        scheme = str(g.value(concept, SKOS.inScheme))
        
        #only include concepts from the ID and Symbol namespaces in Linked Art export
        if scheme == "http://nomisma.org/id/" or scheme == "http://nomisma.org/symbol/":
            entity = {
                "@context": "https://linked.art/ns/v1/linked-art.json",
                "id": str(concept)
            }
            
            #determine class of concept
            if (FOAF.Person in g.objects(concept, RDF.type)) == True:
                entity["type"] = "Person"
            elif (FOAF.Group in g.objects(concept, RDF.type)) == True or (FOAF.Organization in g.objects(concept, RDF.type)) == True or (RDAC.Family in g.objects(concept, RDF.type)) == True:
                entity["type"] = "Group"
            elif (FOAF.Agent in g.objects(concept, RDF.type)) == True:
                entity["type"] = "Actor"
            elif (NMO.Material in g.objects(concept, RDF.type)) == True:
                entity["type"] = "Material"
            elif (CRM.E4_Period in g.objects(concept, RDF.type)) == True:
                entity["type"] = "Period"
            elif (NMO.Mint in g.objects(concept, RDF.type)) == True or (NMO.Region in g.objects(concept, RDF.type)) == True:
                entity["type"] = "Place"
            elif (NMO.Monogram in g.objects(concept, RDF.type)) == True or (CRM.E37_Mark in g.objects(concept, RDF.type)) == True:
                entity["type"] = "Mark"
            elif (SKOS.ConceptScheme in g.objects(concept, RDF.type)) == True:
                entity["type"] = "Set"
            else:
                entity["type"] = "Type"
            
            #labels  
            for label in g.objects(concept, SKOS.prefLabel):
                if label.language == "en":
                    entity["_label"] = str(label)
                    entity["identified_by"] = [
                        {
                            "type": "Name",
                            "content": str(label),
                            "classified_as": [
                                {
                                    "id": "http://vocab.getty.edu/aat/300404670",
                                    "type": "Type",
                                    "_label": "Primary Name"
                                }
                            ]
                        }
                    ]
                    
             
            #classified_as
            if (NMO.Mint in g.objects(concept, RDF.type)) == True:
                entity["classified_as"] = [
                    {
                        "id": "http://vocab.getty.edu/aat/300008347",
                        "type": "Type",
                        "_label": "inhabited places"
                    }
                ]
            elif (NMO.Region in g.objects(concept, RDF.type)) == True:
                entity["classified_as"] = [
                    {
                        "id": "http://vocab.getty.edu/aat/300182722",
                        "type": "Type",
                        "_label": "regions (geographic)"
                    }
                ]
            elif (NMO.Denomination in g.objects(concept, RDF.type)) == True:
                entity["classified_as"] = [
                    {
                        "id": "http://nomisma.org/id/denomination",
                        "type": "Type",
                        "_label": "denomination"
                    }
                ]
            
            classified_as = []
            for type in g.objects(concept, CRM.p2_has_type):
                obj = {
                    "id": type,
                    "type": "Type"
                    }
                classified_as.append(obj)
                
            if len(classified_as) > 0:
                entity["classified_as"] = classified_as
                
            
            for s, p, o in g.triples((concept, None, None)):
                if p == GEO.location:
                    spatialThing = o
                    for s, p, o in g.triples((spatialThing, None, None)):
                        if p == GEO.lat:
                            lat = str(o)
                        if p == GEO.long:
                            long = str(o)
                        if p == OSGEO.asGeoJSON:
                            geoJson = str(o)
                        
                    if lat and long:
                        entity["defined_by"] = f"POINT({long} {lat})"
            
            
    
            response.append(entity)
    
    print(json.dumps(response, indent=4))  

if __name__=="__main__":
    main()