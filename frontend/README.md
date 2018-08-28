# Frontend de NOMS/NMX/Normas
Los tres frontend se encuentran en ramas distintas de desarrollo:

* master    --->  http://noms.imco.org.mx
* nmx    --->  http://nmx.imco.org.mx
* normas    --->  http://normas.imco.org.mx

Para cambiar de ramas utilice el comando de GIT
`git checkout ${BRANCH}`

La construcción del sitio de despliege se ejecuta en la carpeta `frontend`

> #### NOTA:
> Cada sitio debe construirse desde su rama de forma individual.


## Build & development

Run `grunt` for building and `grunt serve` for preview.

## Testing

Running `grunt test` will run the unit tests with karma.
