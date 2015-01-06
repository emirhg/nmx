#! /usr/bin/python3
"""Descarga todos los resumenes del DOF """
# -*- coding: utf-8 -*-
import sys
import urllib.request, json
import os #Para subcarpeta

directory = 'DOFs'
if not os.path.exists(directory):
    os.makedirs(directory)

f = open('logDescargaNOM', 'w')
print("Corriendo la descarga de los resumenes del DOF")
f.write("Corriendo la descarga de los resumenes del DOF")

def iterador_por_mes(mes_inicial, anho_inicio, mes_final, anho_fin):
    """Return an iterator of the months with year"""
    a_inicio = 12 * anho_inicio + mes_inicial - 1
    a_fin = 12 * anho_fin + mes_final 
    for mes in reversed(range(a_inicio, a_fin)):
        year, month = divmod(mes, 12)
        #print ( "Y: %d, m: %d" % (y, m+1))
        yield year, month+1


#http://diariooficial.gob.mx/WS_getDiarioFecha.php?year=2012&month=08
DOF_MESES = 'http://diariooficial.gob.mx/WS_getDiarioFecha.php?year=%d&month=%d'

#http://diariooficial.gob.mx/WS_getDiarioFull.php?year=2013&month=07&day=31
DOF_DIARIO_FULL = 'http://diariooficial.gob.mx/WS_getDiarioFull.php?year=%s&month=%s&day=%s'
NOMBRE_ARCHIVOS = 'DOFs/DiarioFullyear=%s&month=%s&day=%s,json'

count = 0 # 721; #Fix para 2008
f.write("    Id;Anho; Mes;  Dia; FINDNOM")
f.write("\n")


for x in iterador_por_mes(1, 1900, 12, 2014):
    print("Recorriendo  el mes: %2d - %d" % (x[1], x[0]))
    f.write("Recorriendo  el mes: %2d - %d" % (x[1], x[0]))
    try:
        response = urllib.request.urlopen(DOF_MESES%(x[0], x[1]))
        content = response.read()
        data = json.loads(content.decode('utf8')) 
    except:
        data = 0
        print("DOF MESES - Unexpected error:", sys.exc_info()[0])
        f.write("DOF MESES - Unexpected error:", sys.exc_info()[0])
        raise 
    if len(data) > 0:
        dias_del_mes = data['availableDays']
        for dia in reversed(dias_del_mes):
            print("year=%s&month=%s&day=%s" % (x[0], x[1], dia))
            f.write("year=%s&month=%s&day=%s" % (x[0], x[1], dia))
            content2 = ""
            try:
                response = urllib.request.urlopen(DOF_DIARIO_FULL % (x[0], x[1], dia))
                content2 = response.read()
                data2 = json.loads(content2.decode('utf8')) 
                titulo = NOMBRE_ARCHIVOS%(x[0], x[1], dia)
                faux = open( titulo , 'w')
                json.dump(data2, faux)
                faux.close()  
                print("year=%s&month=%s&day=%s OK" % (x[0], x[1], dia))              
                f.write("year=%s&month=%s&day=%s OK" % (x[0], x[1], dia))              
            except:
                print("Unexpected error:", sys.exc_info()[0])
                f.write("Unexpected error:", sys.exc_info()[0])
                raise 
        print("FIN Recorriendo  el mes: %2d - %d OK" % (x[1], x[0]))
        f.write("FIN Recorriendo  el mes: %2d - %d OK" % (x[1], x[0]))
    else:
        print("Unexpected error: data si longitud") 
        f.write("Unexpected error: data si longitud") 

f.close()