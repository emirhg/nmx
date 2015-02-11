# Catalogo de Normas Oficiales Mexicanas
Sistema para la adquisición, clasificación y visualización de las Normas Oficiales Mexicanas publicadas en el Diario Oficial de la Federación.

## Acerca de
La presente aplicación hace uso del API del DOF para identificar las publicaciones referentes a Normas Oficiales Mexicanas y clasificarlas.

## Requerimientos del sistema
 - Python3

## Uso

### Descargar publicaciones
Si se ejecuta sin argumentos recupera los datos de publicación del día actual. Otras variantes son especificar una fecha de inicio, un rango de fechas o X cantidad de días en el pasado

`./src/downloadDOFJSON.py`

Para más información de la ejecución de este script consulta la ayuda del mismo:

`./src/downloadDOFJSON.py -h`

### Identificación de registros de NOMs
Este archivo sólo acepta entradas separadas por <TAB>, dónde cada línea corresponde a una publicación del DOF. Es posible especificar la(s) columna(s) que contienen el JSON de interés mediante el parámetro -f

`./src/identifyNOMpublication.py -f3,5 data/publicacionesDOF.csv`

Este script por el momento carece de documentación interna.

## Contenido
.  
├── LICENSE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Licencia de uso  
├── README.md&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Este archivo  
~~├── 00_bosquejo&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Legacy~~  
├── src  
│   ├── classifyPublication.py  
│   ├── downloadDOFJSON.py&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Descarga las publicaciones del DOF para un rango de fechas  
│   ├── identifyNOMpublication.py&nbsp;&nbsp;&nbsp;Identifica los registros relacionados a una NOM a partir de un JSON  
│   ~~└── utileriaNOMS.py&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Funciones auxiliares.~~  
└── tester.sh  

## Metodología

### downloadDOFJSON.py
La adquisición de las publicaciones del DOF depende de dos servicios:

http://diariooficial.gob.mx/WS_getDiarioFull.php?year=[YYYY]&month=[MM]&day=[DD]  
y
http://diariooficial.gob.mx/BB_DetalleEdicion.php?cod_diario=[NNNNN]  

Inicialmente se consulta *WS_getDiarioFull* para adquirir información sobre la publicación n una fecha determinada, en la mayoría de los casos, este servicio devuelve información suficiente para identificar una poublicación referente a una NOM, sin embargo existen algunas publicaciones de las cuales sólo se menciona al ORGANISMO que publico. Por esta razón una vez consultado *WS_getDiarioFull* extraemos del mismo el "cod_diario" correspondiente a la fecha y utilizamos el servicio *BB_DetalleEdicion* para complementar la información.

*WARNING: BB_DetalleEdicion contiene errores de codificación. Los acentos no se muestran correctamente*

Al final se tiene una tabla, cuyos campos se encuentran separados por tabuladores, con la fecha de la publicación, las dos URLs consultadas y sus respectivas respuestas. Los campos 3 y 5 contienen las respuestas de *WS_getDiarioFull* y *BB_DetalleEdicion* respectivamente.

### identiyfyNOMpublication.py

http://diariooficial.gob.mx/nota_detalle.php?codigo=[NNNNNN]&fecha=[DD/MM/YYYY]
