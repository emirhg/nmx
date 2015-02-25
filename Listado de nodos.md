# Listado de nodos necesarios en la API

0.  Listado de NOMS histórico
1.  Listado de NOMs vigentes/canceladas
2.  Listado de NOMs por dependencia
3.  Información sobre NOM por clave

##  Listado de NOMS histórico

``api/vXX/noms``
Con posibilidad de establecer tamaño de venta y offset.

Un arreglo de objetos que contiene todas las NOMs.

Cada objeto debe de contener:

* Clave estandarizada
* Título (como aparece en el DOF)
* Fecha de publicación
* Codigo dof 
* Link 
* Dependencia
* Comites (arreglo)
* Vigente (0 - no vigente , 1 - vigente , -1 proyecto)

Ejemplo: 
``
[
{
    "clavenom": "NOM-xxx-123-99990",
    "titulo": "NORMA Oficial Mexicana NOM-064-SAG/PESC/SEMARNAT-2013, Sobre sistemas, métodos y técnicas de captura prohibidos en la pesca en aguas de jurisdicción federal de los Estados Unidos Mexicanos.",
    "fecha": "2015-02-17T06:00:00.000Z",
    "clavePublicacionDOF": "5492",
    "link": "http://www.dof.gob.mx/normasOficiales.php?codp=5492&view=si",
    "linkPDF": "http://www.dof.gob.mx/normasOficiales/5492/sct3a11_C/sct3a11_C.html",
    "dependencia": "SCT",
    "comites": ["Comite SCT ", "ComitesCT2 "]
},...] ;
``

## Listado de NOMs vigentes /canceladas

``api/vXX/noms?vigente=1``

Un arreglo de objetos que contiene todas las NOMs sin/con aviso de cancelación o equivalente.


## Listado de NOMs por dependencia

``api/vXX/noms?dependencia="DEPENDENCIAX"``

## Información sobre NOM por clave
``api/vXX/noms/NOM-000-SSSSS-AAA``


Un objecto que contenga:

* Clave estandarizadoa
* Titulo
* Fecha de publicación 
* Dependencia
 Comites (arreglo)
* Vigente (0 - no vigente , 1 - vigente , -1 proyecto)
* Codigo dof 
* Link
* MIR (obejcto en caso de que haya) { link, ...}
* Histórico (publicaciones de dof relacionadas). 
Un arreglo con otras publicaciones ordenado por fecha:
{categoria, fecha, titulo dof, clave dof}
* Noms relacionadas (arreglo) clave de noms de normas relacionadas por estar publicadas en titulos del defo al mismo tiempo*

Ejemplo: 
``
[{
    "clavenom": "NOM-xxx-123-99990",
    "titulo": "NORMA Oficial Mexicana NOM-064-SAG/PESC/SEMARNAT-2013, Sobre sistemas, métodos y técnicas de captura prohibidos en la pesca en aguas de jurisdicción federal de los Estados Unidos Mexicanos.",
    "fecha": "2015-02-17T06:00:00.000Z",
    "clavePublicacionDOF": "5492",
    "link": "http://www.dof.gob.mx/normasOficiales.php?codp=5492&view=si",
    "linkPDF": "http://www.dof.gob.mx/normasOficiales/5492/sct3a11_C/sct3a11_C.html",
    "dependencia": "SCT",
    "comites": ["Comite SCT ", "ComitesCT2 "]
    "publicaciones": [{
        "tipoPublicacion": "Proyecto",
        "titulo": "test",
        "fecha": "12412",
        "clavePublicacionDOF": "21323",
        "link": " fse",
        "linkPDF": "esfe "
    }, {
        "tipoPublicacion": "Respuestas",
        "titulo": "test",
        "fecha": "12412",
        "clavePublicacionDOF": "21323",
        "link": " fse",
        "linkPDF": "esfe "
    }, {
        "tipoPublicacion": "Norma",
        "titulo": "test",
        "fecha": "12412",
        "clavePublicacionDOF": "21323",
        "link": " fse",
        "linkPDF": "esfe "
    }, ...]
}, ...];
``