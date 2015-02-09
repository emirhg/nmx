## Acerca de
La presente aplicación hace uso del API del DOF para identificar las publicaciones referentes a Normas Oficiales Mexicanas y clasficicarlas.

## Ejecución

Descarga el resumen de la publicación de hoy y entuba el resultado para identificar las secciones referentes a NOMs
  ./src/downloadDOFJSON.py | cut -f3 | src/identifyNOMpublication.py

Identifica la publicación y contenido que hacen referencia a una NOM:
  ./src/identifyNOMpublication.py data/publicaciones-DOF.json 2>/dev/null

cut -f3 data/publicacionesDOF.csv | src/identifyNOMpublication.py 2>/dev/null > data/publicacionesNOMs.csv 
csvquery -q 'select distinct id_dof,organo,id_publicacion_dof,fecha_nom,clave_nom_sugerido,clave_normalizada,titulo,url,todas_claves_nom_en_titulo,primera_palabra from csv' data/publicacionesNOMs.csv | xclip -sel clip

## Contenido
src/    Contiene el código fuente de la aplicación
data/   Contiene los archivos de datos referentes a las publicaciones del DOF, estos han sido extraidos del API del DOF

## Metodología
El contenido de las publciaciones del DOF ha sido extraido de la siguiente URL:

http://diariooficial.gob.mx/WS_getDiarioFull.php?year=2013&month=07&day=31
