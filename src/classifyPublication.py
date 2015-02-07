#! /usr/bin/python
# -*- coding: utf-8 -*-

import sys,os,stat
import re


def getWordContext(word,phrase):
    pattern = re.compile('[^\.\(\[]*' + word +'[^\.\)\]]*');
    matches = pattern.findall(str(phrase));
    for idx, val in enumerate(matches):
        val = re.sub('\s*\(.+\)?','', val)
        matches[idx] =  val
    return matches[0];

    

def classify(publicacion):    
    print (publicacion);

def classify():
    publicacion = "NORMA Oficial Mexicana NOM-0-78-1988, productos Generales para uso industrial-materiales refractarios carbón residual, carbón residual aparente y carbón aparente producido en ladrillos y formas especiales alquitranadas coquizadas-método de prueba (cancela a la NOM-0-78-1980)."
    print (getWordContext("NOM-0-78-1988",publicacion));
    print (getWordContext("NOM-0-78-1980",publicacion));


#Main function
def main():
    if len(sys.argv) <= 1:
        mode = os.fstat(0).st_mode
        if stat.S_ISFIFO(mode) or stat.S_ISREG(mode):
            for publicacion in sys.stdin:
                classify(publicacion);
        else:                
            print ('Tienes que especificar un archivo de entrada.');
            print ('Ejemplo: `' + os.path.basename(__file__) + ' input.csv`');
            classify();

    elif len(sys.argv)==2:
        csvInputFile = str(sys.argv[1]);
        with open(csvInputFile) as inputFile:
            for publicacion in inputFile:
                classify(publicacion);

#Ejecución
main();
