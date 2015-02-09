#!/usr/bin/python3

import json, re;
import os,sys;
import html.parser;
import stat
import logging
import getopt


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

def getWordContext(word,phrase):
    pattern = re.compile('[^\.\(\["]*' + word +'[^\.\)\]"]*');
    matches = pattern.findall(str(phrase));
    for idx, val in enumerate(matches):
        val = re.sub('\s*\(.+\)?','', val)
        matches[idx] =  val
    return matches[0];


# Transforma el formato de fecha de 'dia_semana DIA de nombre_mes AÑO' a 'DIA/MES/AÑO'
# viernes 24 de enero 2014 -> 24/01/2014
def parseDate(dateString):
    pattern = re.compile('^\w+\s(\d+)\s\w+\s(\w+)\s(\d{4})$');
    matches = pattern.match(dateString);
    return matches.group(1) + '/' + matches.group(2).replace('enero','01').replace('febrero','02').replace('marzo','03').replace('abril','04').replace('mayo','05').replace('junio','06').replace('julio','07').replace('agosto','08').replace('septiembre','09').replace('octubre','10').replace('noviembre','11').replace('diciembre','12') + '/' + matches.group(3) ;


#Busca y devuelve la clave NOM en una línea de texto.
def getClaveNOM(contentLine):
    pattern = re.compile('((\w+\s*[\-\/]\s*)?NOM(\s*[\-\/\.\s]\s*\w+)+(\s+\d{3})?\d(?=\.))|((\w+\s*[\-\/]\s*)?NOM(\s*[\-\/\.]\s*\w+)+(\s+\d{3})?\d)');
    
    matches = pattern.findall(str(contentLine));
    result = [];
    for match in matches:
        result.append(match[0].replace("nicos- NOM","NOM") if match[0]!= '' else match[4].replace("nicos- NOM","NOM"))
    return result;

def escapeQuotes(string):
    return string.replace('"','""');

#Convierte una string JSON a multiples lineas CSV , una para cada contenido de la publicación
def parseToCSV(publicacionJSON):
    if (publicacionJSON.get('ejemplares')):
        for ejemplar in publicacionJSON['ejemplares']:
            if (ejemplar.get('secciones')):
                for seccion in ejemplar['secciones']:
                    if (seccion['contentsection']['content'].get('content')):
                        for contenido in seccion['contentsection']['content']['content']:
                            #Algunas llaves están codificadas como string en lugar del índice del arreglo y hacemos este truquillo para que no llore.
                            if (type(contenido) is str):
                                contenido = seccion['contentsection']['content']['content'][contenido];
                            for match in getClaveNOM(contenido['titulo']):
                                claveNOM = match;
                                claveNOMnormalizada = re.sub('\-+','\-',claveNOM.replace(" ", "-")).upper();

                                NOMDescription = '"'+escapeQuotes(ejemplar['id']) + '","' + escapeQuotes(parseDate(ejemplar['fecha'])) + '","' + escapeQuotes(seccion['contentsection']['content']['name']) + '","' + escapeQuotes(contenido['id']) + '","' + escapeQuotes(contenido['date']) + '","' + escapeQuotes(claveNOM) + '","' + escapeQuotes(claveNOMnormalizada) + '","' + escapeQuotes(contenido['titulo']) + '","' + escapeQuotes(contenido['url']) + '","' + escapeQuotes(str(set(obtenClavesNOM(contenido['titulo'])))) + '","' + escapeQuotes(obtenTipoNom(contenido['titulo']))+ '"';
                                print( html.parser.HTMLParser().unescape(NOMDescription),end="\n",flush=True);
                                #break;
                    else:
                        logging.warning("No 'contensection.content.content' element in object `"+ json.dumps(seccion) + "`");
            else:
                logging.warning("No 'ejemplares.secciones' element in object `"+ json.dumps(ejemplar) + "`")
    else:
        logging.warning("Extracción de datos en desarrollo");

        

def extractDataFromPublication(publicacion):
    try:
        publicacionJSON = json.loads(publicacion);
        parseToCSV(publicacionJSON);
    except ValueError:
         logging.error("Malformed JSON")


def printHelp():
    #print ('Tienes que especificar un archivo de entrada.');
    print ('Ejemplo: `' + os.path.basename(__file__) + ' input.csv`');

class inputData:
    def __init__(self, inputSrc):
          self.inputSrc = inputSrc;
          
    def __enter__(self):
        if (self.inputSrc=='-'):
            return (sys.stdin);
        else:
            if os.path.isfile(self.inputSrc):
                return open(self.inputSrc)

        logging.critical("Could not open input source: '" + self.inputSrc + "'");
        return [];

    def __exit__(self, type, value, traceback):
        return None;

def json2matrix(jsonObject):
    result = []
    result.append({});
    idx=0
    if (isinstance(jsonObject,list)):
        jsonObj = enumerate(jsonObject);
    else:
        jsonObj = jsonObject;

    if (type(jsonObj) is enumerate or type(jsonObj) is dict):
        for key in jsonObj:
            if type(key) is tuple:
                key = key[0]
            response = json2matrix(jsonObject[key])
            if (isinstance(response,str)):
                auxResponse = response
                result[idx].update({key: auxResponse});

                for key3,value in enumerate(result):
                    if (len(result[key3].keys() - [key]) == len(result[key3].keys())):
                        result[idx].update({key: auxResponse})
                    
            
            else:
                for key2,value in enumerate(response):
                    d = result[idx].copy();
                    d.update(value)
                
                    if (len(result[idx].keys() - value.keys()) == len(result[idx].keys())):
                        result[idx].update(value)
                    else:
                        result.append(result[idx].copy())
                        result[idx+1].update(value)
                        idx = idx +1;
    else:
        result = str(jsonObject);

    return (result)


def getJSONNOMS(plainJson):
    result = []
    
    for entry in plainJson:
        jsonString = json.dumps(entry);

        for match in getClaveNOM(jsonString):
            claveNormalizada = re.sub('[\-\s]+','-',match).upper()
            newEntry = {};
            newEntry.update(entry.copy())
            newEntry.update({'claveNOM' : match, 'claveNOMNormalizada': claveNormalizada ,'contexto': getWordContext(match,jsonString)});
            result.append(newEntry.copy());
    return (result)
        
    
#Main function
def main():

    inputSrc = None;
    columns = [0];
    header = False;
    try:
        opts, args = getopt.getopt(sys.argv[1:],"hi:f:H",["ifile=","fields=","with-header"])
    except getopt.GetoptError:
        printHelp();
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            printHelp();
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputSrc = arg
        elif opt in ("-f", "--fields"):
            columns = arg.split(',');
            for key,value in enumerate(columns):
                columns[key] = int(value)-1
        elif opt in ('-H', '--with-header'):
            header=True;

    if stat.S_ISFIFO(os.fstat(0).st_mode) or stat.S_ISREG(os.fstat(0).st_mode):
        inputSrc = '-';
    elif not(inputSrc) and args:
        inputSrc = str(args[0]);
    if not(inputSrc):
        printHelp();
    else:
        headerKeys = [];
        with inputData(inputSrc) as data:
            for publicacion in data:
                splitedPublicacion = publicacion.split("\t");
                for colIdx in columns:
                    try:
                        jsonObject = json.loads(splitedPublicacion[colIdx]);
                    except ValueError:
                         logging.error("Malformed JSON")

                    plainJson = json2matrix(jsonObject);
                    
                    for nom in getJSONNOMS(plainJson):
                        # Obtiene las claves del JSON
                        for key in nom:
                            if (key not in headerKeys):
                                headerKeys.append(key)
                        for key in headerKeys:
                            if (key in nom):
                                print ('"'+escapeQuotes(nom[key]) + '"', end="")
                            else:
                                print ('""', end="")
                            if (key != headerKeys[-1]):
                                print(",", end="")
                            else:
                                print ("")
                    
                    #extractDataFromPublication(splitedPublicacion[colIdx]);
    if (header):
        for key in headerKeys:
            if (key != headerKeys[-1]):
                print(key, end=",")
            else:
                print (key)

#Ejecución
main();
