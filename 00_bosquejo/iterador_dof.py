#!python
"""Carga los archivos del DOF para buscar NOMS"""
# -*- coding: utf-8 -*-
import sys
import urllib.request, json
print("Version de python: ", sys.version)
print("Se recomiendo >3")
def iterador_por_mes(mes_inicial, anho_inicio, mes_final, anho_fin):
    """Return an iterator of the months with year"""
    a_inicio = 12 * anho_inicio + mes_inicial - 1
    a_fin = 12 * anho_fin + mes_final 
    for mes in reversed(range(a_inicio, a_fin)):
        year, month = divmod(mes, 12)
        #print ( "Y: %d, m: %d" % (y, m+1))
        yield year, month+1

def find_values(id, json_repr):
    """Encuentra los valores bajo la llave id"""
    results = []

    def _decode_dict(a_dict):
        """Usa decode_dict"""
        try: 
            results.append(a_dict[id])
        except KeyError: 
            pass
        return a_dict

    json.loads(json_repr, object_hook=_decode_dict)  # return value ignored
    return results

#http://diariooficial.gob.mx/WS_getDiarioFecha.php?year=2012&month=08
DOF_MESES = 'http://diariooficial.gob.mx/WS_getDiarioFecha.php?year=%d&month=%d'

#http://diariooficial.gob.mx/WS_getDiarioFull.php?year=2013&month=07&day=31
DOF_DIARIO_FULL = 'http://diariooficial.gob.mx/WS_getDiarioFull.php?year=%s&month=%s&day=%s'
count = 721; #Fix para 2008
print("Id;Anho;Mes;Dia")
for x in iterador_por_mes(6, 1992, 12, 2008):
    #print("Recorriendo  el mes: %2d - %d" % (x[1], x[0]))
    try:
        response = urllib.request.urlopen(DOF_MESES%(x[0], x[1]))
        content = response.read()
        data = json.loads(content.decode('utf8')) 
        #print(data['availableDays'])
    except:
        print("Unexpected error:", sys.exc_info()[0])
        raise 
    if len(data) > 0:
        dias_del_mes = data['availableDays']
        #print("Num dias: ", len(dias_del_mes))
        for dia in reversed(dias_del_mes):
            #print("Dia: %s/%2d/%d"%(y, x[1], x[0]))
            try:
                response = urllib.request.urlopen(DOF_DIARIO_FULL%(x[0], x[1], dia))
                content = response.read()
                #data = json.loads(content.decode('utf8')) 
                if content.decode('utf8').find('NOM-') != -1: 
                    #print(find_values('titulo', data))
                    count += 1
                    print("%6d;%2d;%4d;%s"%(count, x[0], x[1], dia))
            except:
                print("Unexpected error:", sys.exc_info()[0])
                raise 




