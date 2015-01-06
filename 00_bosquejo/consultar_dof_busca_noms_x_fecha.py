#! /usr/bin/python3
"""Carga los archivos del DOF para buscar NOMS"""
# -*- coding: utf-8 -*-

import sys, urllib.request, json
#import dicttoxml
def dict2xml(d, root_node=None):
    wrap          =     False if None == root_node or isinstance(d, list) else True
    root          = 'objects' if None == root_node else root_node
    root_singular = root[:-1] if 's' == root[-1] and None == root_node else root
    xml           = ''
    children      = []
 
    if isinstance(d, dict):
        for key, value in dict.items(d):
            if isinstance(value, dict):
                children.append(dict2xml(value, key))
            elif isinstance(value, list):
                children.append(dict2xml(value, key))
            else:
                xml = xml + ' ' + key + '="' + str(value) + '"'
    else:
        for value in d:
            children.append(dict2xml(value, root_singular))
 
    end_tag = '>' if 0 < len(children) else '/>'
 
    if wrap or isinstance(d, dict):
        xml = '<' + root + xml + end_tag
 
    if 0 < len(children):
        for child in children:
            xml = xml + child
 
        if wrap or isinstance(d, dict):
            xml = xml + '</' + root + '>'
        
    return xml

DOF_DIARIO_FULL = 'http://diariooficial.gob.mx/WS_getDiarioFull.php?year=%s&month=%s&day=%s'

def busca_noms_por_fecha_en_dof(anho, mes, dia):
    """Regresa un arreglo con los datos de los nodos que información de las NOMS"""
    data = ''
    try:
        response = urllib.request.urlopen(DOF_DIARIO_FULL%(anho, mes, dia))
        content = response.read()
        data = json.loads(content.decode('utf8')) 
        print(dict2xml(data))
    except:
        print("Unexpected error:", sys.exc_info()[0])
        raise
    if len(data) > 0:
        print("Buscar mat-: %d"%(content.decode('utf8').find('NOM-')))
        print(json.dumps(data['ejemplares']))
        for ejemplar in data['ejemplares']:
            print(json.dumps(ejemplar['edicion']))
            for seccion in ejemplar["secciones"]:
                if "content" in seccion["contentsection"]["content"]: 
                    print(json.dumps(seccion["contentsection"]["content"]["content"]))
                    #for cont in seccion["contentsection"]["content"]["content"]:
                        #
                #else:

                    #print(json.dumps(seccion["contentsection"]["content"]))
        return data

datos = busca_noms_por_fecha_en_dof(1984, 6, '20')
