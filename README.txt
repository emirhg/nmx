=== Acerca de ===
La presente aplicación hace uso del API del DOF para identificar las publicaciones referentes a Normas Oficiales Mexicanas y clasficicarlas.

=== Ejecución ===
Identifica la publicación y contenido que hacen referencia a una NOM:
  ./src/identifyNOMpublication.py data/publicaciones-DOF.json 2>/dev/null


=== Contenido ===
src/    Contiene el código fuente de la aplicación
data/   Contiene los archivos de datos referentes a las publicaciones del DOF, estos han sido extraidos del API del DOF

=== Metodología ===
El contenido de las publciaciones del DOF ha sido extraido de la siguiente URL:

http://diariooficial.gob.mx/WS_getDiarioFull.php?year=2013&month=07&day=31
