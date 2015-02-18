#! /usr/bin/python3
# -*- coding: utf-8 -*-

from csvutils import escapeQuotes
import time,sys,os
import urllib.request,json
from datetime import date
from datetime import timedelta

DOF_DIARIO_FULL = 'http://diariooficial.gob.mx/WS_getDiarioFull.php?year=%s&month=%s&day=%s'
BB_DETALLEEDICION = "http://diariooficial.gob.mx/BB_DetalleEdicion.php?cod_diario=%s"
#DEBUG = True;

def getCodigoDiario(dof):
    ejemplares = []
    for ejemplar in dof['ejemplares']:
        ejemplares.append(ejemplar['id'])
    return ejemplares;

def getJSON(urlRequest):
    response = urllib.request.urlopen(urlRequest)
    content = response.read()
    data = json.loads(content.decode('utf8')) 
    return data

def printHelp():
    print ('Este script sirve para descargar el resumen de las publicaciones del DOF en un periodo determinado:')
    print ("\n\t" + os.path.basename(__file__) + " [DIAS | [FECHA_INICIO [FECHA_FINAL]]");
    print ("\nEl formato de fecha es %Y-%m-%d")
    print ("\n\nEjemplo:\n\t" + os.path.basename(__file__) + " 2\t\t\t\t Recupera las publicaciones de los últimos 2 días");
    print ("\t" + os.path.basename(__file__) + " 1900-1-1\t\t\t Recupera las apartir del 1 de enero de 1900");
    print ("\t" + os.path.basename(__file__) + " 1900-1-1 1900-1-5\t\t Recupera las apartir del 1 de enero de 1900 hasta el 5 de enero de 1900");
    print ("\t" + os.path.basename(__file__) + " \t\t\t\t Descarga el día actual");
    sys.exit();

if __name__ == "__main__":
    if len(sys.argv) <= 1:
        startDate = date.today()
        endDate = date.today()
        delta = timedelta(days = 0)
    else:
        if (sys.argv[1]=='-h' or sys.argv[1]=='--help' or sys.argv[1]=='?'):
            printHelp()
        elif len(sys.argv) == 2:
            endDate = date.today()
            if (sys.argv[1].isdigit()):
                delta = timedelta(days=int(sys.argv[1]))
                startDate = endDate - delta
            else:
                startDate = date.fromtimestamp(time.mktime(time.strptime(sys.argv[1],'%Y-%m-%d')));
                delta = endDate - startDate
        elif len(sys.argv) == 3:
            endDate = date.fromtimestamp(time.mktime(time.strptime(sys.argv[2],'%Y-%m-%d')));
            startDate = date.fromtimestamp(time.mktime(time.strptime(sys.argv[1],'%Y-%m-%d')));
            delta = endDate - startDate
    if (delta.days<0):
        printHelp()

    print ('"fecha","URL","respuesta","encoding"')

    for i in range (0,delta.days+1):
        thisDate = startDate + timedelta(days=i)
        response = getJSON(DOF_DIARIO_FULL % (thisDate.year, thisDate.month, thisDate.day))

        print ('"%s-%s-%s"' % (thisDate.year,thisDate.month,thisDate.day) + ',"'+ DOF_DIARIO_FULL % (thisDate.year, thisDate.month, thisDate.day) + '"', end="")
        print (',"' + escapeQuotes(json.dumps(response)) + '","html-entity"')

        clave_dof = getCodigoDiario(response)
            
        for idDOF in clave_dof:
            detalle = getJSON(BB_DETALLEEDICION % (idDOF))
            print ('"%s-%s-%s"' % (thisDate.year,thisDate.month,thisDate.day), end="")
            print (',"' + BB_DETALLEEDICION % (idDOF) + '","' + escapeQuotes(json.dumps(detalle)) + '","bad-encoding"')
