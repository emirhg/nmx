#!/usr/bin/python3
# -*- coding: utf-8 -*-

import json, re;
import os,sys;
import html.parser;
import stat
import logging
import getopt
import tempfile
import collections
from csvutils import escapeQuotes


## Técnicamente es el tipo de publicación de la NOM (Comentario/Publicación/Cancelación/Fe de errata/etc...)
## Se considera la primera palabra (sólo la primera palabra) en el título de la publicación
def obtenTipoNom(linea):
    """ Obtiene por ahora la primera palabra del título, tendría que regresar de que se trata"""
    return linea.partition(' ')[0]

def getWordContext(word,phrase):
    word = html.parser.HTMLParser().unescape(word)
    phrase = html.parser.HTMLParser().unescape(phrase);
    
    pattern = re.compile('[^\.\(\["]*' + re.escape(word) +'[^\.\)\]"]*');
    matches = pattern.findall(str(phrase));
    for idx, val in enumerate(matches):
        val = re.sub('\s*\(.+\)?','', val)
        matches[idx] =  val
    result = None if matches== None else matches[0];
    return result;

# Transforma el formato de fecha de 'dia_semana DIA de nombre_mes AÑO' a 'DIA/MES/AÑO'
# viernes 24 de enero 2014 -> 24/01/2014
def parseDate(dateString):
    pattern = re.compile('^(?:[^\d]+\s)?(\d+)(?:\s\w+\s|\-)(\w+)[\s\-]((?:\d{2}){1,2})$');
    matches = pattern.match(dateString);
    
    if matches:
        year = matches.group(3);
        
        if (len(matches.group(3))==2):
            if (int(matches.group(3))<30):
                year = '20' +matches.group(3)
            else:
                year = '19' +matches.group(3)
        return matches.group(1) + '/' + matches.group(2).lower().replace('enero','01').replace('febrero','02').replace('marzo','03').replace('abril','04').replace('mayo','05').replace('junio','06').replace('julio','07').replace('agosto','08').replace('septiembre','09').replace('octubre','10').replace('noviembre','11').replace('diciembre','12').replace('jan','01').replace('feb','02').replace('mar','03').replace('apr','04').replace('may','05').replace('jun','06').replace('jul','07').replace('aug','08').replace('sep','09').replace('oct','10').replace('nov','11').replace('dec','12') + '/' + year ;
    else:
        return dateString;

#Busca y devuelve la clave NOM en una línea de texto.
def getClaveNOM(contentLine):
    contentLine = html.parser.HTMLParser().unescape(contentLine);
    #regexpr = '(((\w+\s*[\-\/]\s*)?NOM(\s*[\-\/\.\s]\s*\w+)+(\s+\d{3})?\d(?=\.))|((\w+\s*[\-\/]\s*)?NOM(\s*[\-\/\.]\s*\w+)+(\s+\d{3})?\d))';
    # Eficiencia de la expresión regular
    # Descripción,total
    # Claves NOMs,3942
    # NOMs faltantes,43
    # Registros identificados,16828
    
    regexpr = '((?:norma\s+oficial\s+mexicana\s*(?:espec.{1,2}fica\s*)?(?:de\s+emergencia,?\s*(?:denominada\s*)?)?(?:\(?\s*emergente\s*\)?\s*)?(?:\(?\s*con\s+\car.{1,2}cter\s+(?:de\s+emergencia|emergente)\s*\)?\s*,?\s*)?(?:\s*n.{1,2}mero\s*)?(?:\s*\-\s*)?\s)|(?P<prefijo>(?<=[^\w])(\w+\s*[\-\/]\s*)*?NOM(?:[-.\/]|\s+[^a-z])+))(?P<clave>(?:[^;"]+?)(?:\s*(?:(?=[,.]\s|[;"]|[^\d-]\s[^\d])|\d{4}|\d(?=\s+[^\d]+[\s,;:]))))';
    # Eficiencia de la expresión regular
    # Descripción,total
    # Claves NOMs,4048
    # NOMs faltantes,43
    # Registros identificados,20685


    matches = re.findall(regexpr, contentLine, re.IGNORECASE)
    
    result = [];
    
    for match in matches:
        #claveCorregida = match[0];
        claveCorregida = match[1] + match[-1]
        claveCorregida = claveCorregida.replace("nicos- NOM","NOM").replace("\\fNOM","NOM")
        claveCorregida = re.sub('^[^\d]+$',' ',claveCorregida)
        
        result.append(claveCorregida)

    return result;

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

    if (type(jsonObj) is enumerate or type(jsonObj) is dict or type(jsonObj) is collections.OrderedDict):
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

def normalizaClaveNOM(claveNOM):
    claveNOM = claveNOM.upper();
    claveNOM = re.sub('\s*/\s*','/',claveNOM)
    claveNOM = re.sub('[\-\s]+','-',claveNOM)
    
    claveSplited = claveNOM.split("-");

    #Ajusta la clave númerica a 3 dígitos
    if(len(claveSplited)>=2 and  claveSplited[1].isnumeric()):
        while len(claveSplited[1]) < 3:
            claveSplited[1] = '0' + claveSplited[1];
    elif(len(claveSplited)>=3 and claveSplited[2].isnumeric()):
        while len(claveSplited[2]) < 3:
            claveSplited[2] = '0' + claveSplited[2];

    # Normaliza las claves de las secretarias
    if(len(claveSplited)>=3 and not claveSplited[2].isnumeric()):
        claveSplited[2] = re.sub('^CNA$','CONAGUA', claveSplited[2])
        claveSplited[2] = re.sub('^RECNAT$','SEMARNAT', claveSplited[2])
    elif(len(claveSplited)>=4 and not claveSplited[3].isnumeric()):
        claveSplited[3] = re.sub('^CNA$','CONAGUA', claveSplited[3])
        claveSplited[3] = re.sub('^RECNAT$','SEMARNAT', claveSplited[3])
    

    #Ajusta el año a 4 dígitos
    if(claveSplited[-1].isnumeric() and len(claveSplited[-1])==2):
        if (int(claveSplited[-1])>20):
            claveSplited[-1] = '19' + claveSplited[-1];
        else:
            claveSplited[-1] = '20' + claveSplited[-1];
    
    claveNOM = '-'.join(claveSplited);
    return claveNOM

def getJSONNOMS(plainJson):
    result = []
    for entry in plainJson:
        
        jsonString = str(json.dumps(entry));
        clavesNOM = getClaveNOM(jsonString);
        for match in clavesNOM:
            claveNormalizada = re.sub('[\-\s]+','-',str(match)).upper()
            claveNormalizada = normalizaClaveNOM(str(match))
            contexto = getWordContext(str(match),jsonString);
            tipo = obtenTipoNom(contexto);

            if (tipo.upper() == 'PROYECTO' and 'PROY-' not in claveNormalizada[:5]):
                claveNormalizada = 'PROY-' + claveNormalizada
            
            newEntry = {};
            newEntry.update(entry.copy())
            newEntry.update({'claveNOM' : match, 'claveNOMNormalizada': claveNormalizada ,'contexto': contexto, 'tipoPublicacion': tipo});
            result.append(newEntry.copy());
        
    return (result)
        
    
#Main function
if __name__ == "__main__":
    inputSrc = None;
    columns = [0];
    header = False;
    tmpFile = tempfile.NamedTemporaryFile(delete=True)
    
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
                        jsonString = splitedPublicacion[colIdx] if splitedPublicacion[colIdx][0]!='"' else splitedPublicacion[colIdx][1:-2].replace('""','"')
                        #print(jsonString)
                        jsonObject = json.JSONDecoder(object_pairs_hook=collections.OrderedDict).decode((str(jsonString)))
                    except ValueError:
                         logging.error("Malformed JSON")
                         break;

                    plainJson = json2matrix(jsonObject);
                    jsonNOMS = getJSONNOMS(plainJson);
                    
                    for nom in jsonNOMS:
                        #tmpFile.write (bytes('"'+html.parser.HTMLParser().unescape(escapeQuotes(json.dumps(nom))) + '",', 'UTF-8'));
                        # Obtiene las claves del JSON
                        for key in nom:
                            if (key not in headerKeys):
                                headerKeys.append(key)
                        for key in headerKeys:
                            #keyAux = key;
                            #if keyAux.lower()=='id':
                            #    keyAux='cod_nota'
                            #elif keyAux.lower() =='date':
                            #    keyAux='fecha'
                            #elif keyAux.lower() =='tituloDecreto':
                            #    keyAux='titulo'
                                
                            #Imprime los valores en la columna correspondiente
                            if (key in nom):
                                if key=='fecha':
                                    nom[key] = parseDate(nom[key])
                                tmpFile.write(bytes('"'+html.parser.HTMLParser().unescape(escapeQuotes(nom[key])) + '"', 'UTF-8'))
                            else:
                                tmpFile.write (bytes('""', 'UTF-8'))
                            # Separador si aún existen elemento o salto de línea si es el último
                            if (key != headerKeys[-1]):
                                tmpFile.write(bytes(',', 'UTF-8'))
                            else:
                                tmpFile.write(bytes("\n", 'UTF-8'))
    if (header):
        #print ("objeto",end=",")
        for key in headerKeys:
            if (key != headerKeys[-1]):
                print(key, end=",")
            else:
                print (key)
    with open(tmpFile.name) as tmpData:
        for line in (tmpData):
            print (line, end="")
