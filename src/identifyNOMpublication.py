#!/usr/bin/python3

import json, re;
import os,sys;
import html.parser;
import stat

## Versión de Hugo para múltiples NOMs en la misma línea
def obtenClavesNOM(linea):
    """ Obtiene un grupo de string que cumplen el patron de clave NOM """
    res = re.findall('(?:PROY-)*NOM-[0-9\- A-Z\\\\\/]*', linea)
    return res

## Técnicamente es el tipo de publicación de la NOM (Comentario/Publicación/Cancelación/Fe de errata/etc...)
## Se considera la primera palabra (sólo la primera palabra) en el título de la publicación
def obtenTipoNom(linea):
    """ Obtiene por ahora la primera palabra del título, tendría que regresar de que se trata"""
    #res = linea.split('\t')
    return linea.partition(' ')[0]


# Transforma el formato de fecha de 'dia_semana DIA de nombre_mes AÑO' a 'DIA/MES/AÑO'
# viernes 24 de enero 2014 -> 24/01/2014
def parseDate(dateString):
    pattern = re.compile('^\w+\s(\d+)\s\w+\s(\w+)\s(\d{4})$');
    matches = pattern.match(dateString);
    return matches.group(1) + '/' + matches.group(2).replace('enero','01').replace('febrero','02').replace('marzo','03').replace('abril','04').replace('mayo','05').replace('junio','06').replace('julio','07').replace('agosto','08').replace('septiembre','09').replace('octubre','10').replace('noviembre','11').replace('diciembre','12') + '/' + matches.group(3) ;


#Busca y devuelve la clave NOM en una línea de texto.
def getClaveNOM(contentLine):
    pattern = re.compile('((\w+\s*[\-\/]\s*)?NOM(\s*[\-\/]\s*\w+)+)');
    matches = pattern.findall(str(contentLine));
    return matches;

def escapeQuotes(string):
    return string.replace('"','""');

#Convierte una string JSON a multiples lineas CSV , una para cada contenido de la publicación
def parseToCSV(publicacion):
    publicacionJSON = json.loads(publicacion);

    for ejemplar in publicacionJSON['ejemplares']:
        if (ejemplar.get('secciones')):
            for seccion in ejemplar['secciones']:
                if (seccion['contentsection']['content'].get('content')):
                    for contenido in seccion['contentsection']['content']['content']:
                        #Algunas llaves están codificadas como string en lugar del índice del arreglo y hacemos este truquillo para que no llore.
                        if (type(contenido) is str):
                            contenido = seccion['contentsection']['content']['content'][contenido];
                        for match in getClaveNOM(contenido['titulo']):
                            claveNOM = match[0].replace(" ", "").upper();

                            NOMDescription = '"'+escapeQuotes(ejemplar['id']) + '","' + escapeQuotes(parseDate(ejemplar['fecha'])) + '","' + escapeQuotes(seccion['contentsection']['content']['name']) + '","' + escapeQuotes(contenido['id']) + '","' + escapeQuotes(contenido['date']) + '","' + escapeQuotes(claveNOM) + '","' + escapeQuotes(contenido['titulo']) + '","' + escapeQuotes(contenido['url']) + '","' + escapeQuotes(str(set(obtenClavesNOM(contenido['titulo'])))) + '","' + escapeQuotes(obtenTipoNom(contenido['titulo']))+ '"';
                            print( html.parser.HTMLParser().unescape(NOMDescription),end="\n",flush=True);
                else:
                    print("WARNING: No 'contensection.content.content' element in object `", seccion , file=sys.stderr,flush=True);
        else:
            print("WARNING: No 'ejemplares.secciones' element in object `", ejemplar, file=sys.stderr,flush=True)

#Main function
def main():
    if len(sys.argv) <= 1:
        mode = os.fstat(0).st_mode
        if stat.S_ISFIFO(mode) or stat.S_ISREG(mode):
            print ('"id_dof","fecha","organo","id_publicacion_dof","fecha_nom","clave_nom_sugerido","titulo","url","todas_claves_nom_en_titulo","primera_palabra"');
            for publicacion in sys.stdin:
                parseToCSV(publicacion);
        else:                
            print ('Tienes que especificar un archivo de entrada.');
            print ('Ejemplo: `' + os.path.basename(__file__) + ' input.json`');

    elif len(sys.argv)==2:
        jsonInputFileName = str(sys.argv[1]);
        print ('"id_dof","fecha","organo","id_publicacion_dof","fecha_nom","clave_nom_sugerido","titulo","url","todas_claves_nom_en_titulo","primera_palabra"');
        with open(jsonInputFileName) as inputFile:
            for publicacion in inputFile:
                parseToCSV(publicacion);

#Ejecución
main();
