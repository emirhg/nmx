#!/usr/bin/python3

import json, re
import os, sys

def obtenClavesNOM(linea):
    """ Obtiene un grupo de string que cumplen el patron de clave NOM """
    res = re.findall('(?:PROY-)*NOM-[0-9\- A-Z\\\\\/]*', linea)
    return res

def obtenTipoNom(linea):
    """ Obtiene por ahora la primera palabra del título, tendría que regresar de que se trata"""
    res = linea.split('\t')
    return res[6].partition(' ')[0]


def main():
    """" Main function """
#   ¬_¬
#   sys.argv = r'C:\Taller\009_IMCO\noms\data\publicacionesNOMs-acentos.csv'
    if len(sys.argv) <= 1:
        print('Tienes que especificar un archivo de entrada.')
        print('Ejemplo: `' + os.path.basename(__file__) + ' input.json`')
    else:
        counter=1
        inputFile = sys.argv[1]
        with open(inputFile, "r", encoding='utf-8') as inputFileOpened:
            for linea in inputFileOpened:
                grupo = obtenClavesNOM(linea)
                tipo = obtenTipoNom(linea)
                print(str(set(grupo)) +  '\t' + tipo)

#Ejecución
main()
