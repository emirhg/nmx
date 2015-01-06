#!/usr/bin/python3

import json, re;
import os,sys;

# Transforma el formato de fecha de 'dia_semana DIA de nombre_mes AÑO' a 'DIA/MES/AÑO'
# viernes 24 de enero 2014 -> 24/01/2014
def parseDate(dateString):
    pattern = re.compile('^\w+\s(\d+)\s\w+\s(\w+)\s(\d{4})$');
    matches = pattern.match(dateString);
    return matches.group(1) + '/' + matches.group(2).replace('enero','01').replace('febrero','02').replace('marzo','03').replace('abril','04').replace('mayo','05').replace('junio','06').replace('julio','07').replace('agosto','08').replace('septiembre','09').replace('octubre','10').replace('noviembre','11').replace('diciembre','12') + '/' + matches.group(3) ;

#Verifica que el contenido corresponda a una NOM e imprime la linea
def validaNOM(contentLine):
    pattern = re.compile('.*NOM\-.*');
    matches = pattern.match(contentLine);
    if (matches!=None):
        result = True;
    else:
        result = False;
    return result;

#Convierte una string JSON a multiples lineas TSV , una para cada contenido de la publicación
def parseToCSV(publicacion):
    publicacionJSON = json.loads(publicacion);
    index=0;
    result = [];
    for ejemplar in publicacionJSON['ejemplares']:
        for seccion in ejemplar['secciones']:
            for contenido in seccion['contentsection']['content']['content']:
                contentLine = (ejemplar['id'] + '\t' + parseDate(ejemplar['fecha']) + '\t' + ejemplar['edicion'] + '\t' + seccion['secc']+ '\t' + seccion['contentsection']['name']+ '\t' + seccion['contentsection']['content']['name'] + '\t' + contenido['id'] + '\t' + contenido['date'] + '\t' + contenido['titulo'] + '\t' + contenido['url']);
                if(validaNOM(contenido['titulo'])):
                    print(contentLine);
#Main function
def main():
    if len(sys.argv) <= 1:
        print ('Tienes que especificar un archivo de entrada.');
        print ('Ejemplo: `' + os.path.basename(__file__) + ' input.json`');
    else:
        jsonInputFileName = str(sys.argv[1]);#'../data/publicaciones-dof.json';
        with open(jsonInputFileName) as inputFile:
            for publicacion in inputFile:
                parseToCSV(publicacion);

#Ejecución
main();
