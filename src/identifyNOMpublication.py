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

#Busca y devuelve la clave NOM en una línea de texto.
def getClaveNOM(contentLine):
    pattern = re.compile('.*(NOM(\-[\s\w\d]+)+).*');
    matches = pattern.match(contentLine);
    if (matches!=None):
        result = matches.group(1);
    else:
        result = False;
    return result;

#Convierte una string JSON a multiples lineas TSV , una para cada contenido de la publicación
def parseToCSV(publicacion):
    publicacionJSON = json.loads(publicacion);
    index=0;
    result = [];
    for ejemplar in publicacionJSON['ejemplares']:
        if (ejemplar.get('secciones')):
            for seccion in ejemplar['secciones']:
                if (seccion['contentsection']['content'].get('content')):
                    for contenido in seccion['contentsection']['content']['content']:
                        if (type(contenido) is str):
                            contenido = seccion['contentsection']['content']['content'][contenido];

                        claveNOM = getClaveNOM(contenido['titulo']);
                        contentLine = (ejemplar['id'] + '\t' + parseDate(ejemplar['fecha']) + '\t' + ejemplar['edicion'] + '\t' + seccion['secc']+ '\t' + seccion['contentsection']['name']+ '\t' + seccion['contentsection']['content']['name'] + '\t' + contenido['id'] + '\t' + contenido['date'] + '\t' + contenido['titulo'] + '\t' + contenido['url']);

                        if(claveNOM):
                            NOMDescription = ejemplar['id'] + '\t' + parseDate(ejemplar['fecha']) + '\t' + seccion['contentsection']['content']['name'] + '\t' + contenido['id'] + '\t' + contenido['date'] + '\t' + claveNOM + '\t' + contenido['titulo'] + '\t' + contenido['url'];
                            print(NOMDescription);
                else:
                    print("WARNING: ", seccion, file=sys.stderr);
        else:
            print("WARNING: ", ejemplar, file=sys.stderr)

#Main function
def main():
    if len(sys.argv) <= 1:
        print ('Tienes que especificar un archivo de entrada.');
        print ('Ejemplo: `' + os.path.basename(__file__) + ' input.json`');
    else:
        counter=1;
        jsonInputFileName = str(sys.argv[1]);
        with open(jsonInputFileName) as inputFile:
            for publicacion in inputFile:
                if(validaNOM(publicacion)):
                    parseToCSV(publicacion);

#Ejecución
main();
