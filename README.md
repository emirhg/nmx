# Catalogo de Normas Oficiales Mexicanas
Sistema para la adquisición, clasificación y visualización de las Normas Oficiales Mexicanas publicadas en el Diario Oficial de la Federación.

## Acerca de
La presente aplicación hace uso del API del DOF para identificar las publicaciones referentes a Normas Oficiales Mexicanas y clasificarlas.

## Requerimientos del sistema
 - PostgreSQL >= 9.3
 - postgresql-plpython3
 - Python 3.2+
 - nltk http://www.nltk.org/install.html


## Instalación

### Frontend
El Frontend está dividido en 3 ramas distintas de desarrollo, cada una conteniendo un portal distintito para NOM, NMX y la página principal de NORMAS.

* master    http://noms.imco.org.mx
* Normas    http://normas.imco.org.mx
* nmx       http://nmx.imco.org.m

#### Requerimientos
* Node & NPM
* Bower

#### Construccion
Si se desea cambiar el API este debe ser especificado en cada una de las ramas en las cuales se vaya a implementar la ruta deseada. La ruta del API está especificada en la variable `baseurl` del archivo `app/scripts/services/datos.js`


```
app/scripts/services/datos.js:        var baseurl = 'http://apiv3.dev.imco.org.mx/catalogonoms';

```

La construcción del sitio es cómo cualquier otra aplicación de angular. EL siguiente script itera cobre las ramas involucradas y copia el resultado de la construcción a lña carpeta $HOME del usuario.

```
export PUBLIC_WEB_ROOT=$HOME
echo "Los sitios web seran copiados a la carpeta $PUBLIC_WEB_ROOT"

cd frontend
npm install
bower install

for branch in "master" "Normas" "nmx"
do
  git checkout ${branch}
  grunt build
  mv dist ${PUBLIC_WEB_ROOT}/${branch}
done

ls -lat ${PUBLIC_WEB_ROOT} | head
```

### Base de datos
El archivo SQL de configuración debe ser ejecutado por un Superusuario, algunas funciones fuerón escritas en PlPython3 y se requiere de un superusuario para crear el SP.

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
│   ├── identifyNOMpublication.py&nbsp;&nbsp;&nbsp;Identifica los registros relacionados a una NOM  
│   
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

## TODO
 - Vincular las NOMs que cambian de nombre pero siguen siendo la misma
 - Eliminar duplicados de notas al insertar en DB
 - Normalizar los separadores de campos en la clave de la nom (entre secretaria y año existen casos con "/")
 - Corregir títulos con caráctares extraños (error en el DOF al insertar en DB con mala codificación), i.e., recuperar el mejor registro disponible
 - Ajuste más fino de la Expresión Regular para extraer claves de NOMs (NOM - 115 - STPS - 1994 se captura como NOM-115; NOM-023-  \fPESC-1996 => NOM-023-)
