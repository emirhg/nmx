## Acerca de
La presente aplicación hace uso del API del DOF para identificar las publicaciones referentes a Normas Oficiales Mexicanas y clasificarlas.

## Ejecución

Descarga el resumen de la publicación de hoy y entuba el resultado para identificar las secciones referentes a NOMs:

`./src/downloadDOFJSON.py | cut -f3 | src/identifyNOMpublication.py`

Identifica la publicación y contenido que hacen referencia a una NOM:

`./src/identifyNOMpublication.py data/publicaciones-DOF.json 2>/dev/null`

### Pruebas
```
./src/downloadDOFJSON.py 2003-12-8 2003-12-8
cut -f3 data/publicacionesDOF.csv | src/identifyNOMpublication.py 2>/dev/null > data/publicacionesNOMs.csv 
csvquery -q 'select distinct id_dof,organo,id_publicacion_dof,fecha_nom,clave_nom_sugerido,clave_normalizada,titulo,url,todas_claves_nom_en_titulo,primera_palabra from csv' data/publicacionesNOMs.csv | xclip -sel clip
```

## Contenido
`src/`    Contiene el código fuente de la aplicación  
`data/`   Contiene los archivos de datos referentes a las publicaciones del DOF, estos han sido extraidos del API del DOF

## Metodología

La adquisición de las publicaciones del DOF depende de dos servicios:

http://diariooficial.gob.mx/WS_getDiarioFull.php?year=2013&month=07&day=31  
y
http://diariooficial.gob.mx/BB_DetalleEdicion.php?cod_diario=28054  

Inicialmente se consulta *WS_getDiarioFull* para adquirir información sobre la publicación n una fecha determinada, en la mayoría de los casos, este servicio devuelve información suficiente para identificar una poublicación referente a una NOM, sin embargo existen algunas publicaciones de las cuales sólo se menciona al ORGANISMO que publico. Por esta razón una vez consultado *WS_getDiarioFull* extraemos del mismo el "cod_diario" correspondiente a la fecha y utilizamos el servicio *BB_DetalleEdicion* para complementar la información.

*WARNING: BB_DetalleEdicion contiene errores de codificación. Los acentos no se muestran correctamente*

Al final obtenemos una tabla con la fecha de la publicación, las dos URLs consultadas y sus respentivas respuestas.

http://diariooficial.gob.mx/nota_detalle.php?codigo=685002&fecha=08/12/2003

