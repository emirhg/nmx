'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:NormasCtrl
 * @description
 * # NormasCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('NormasCtrl', function($scope, $location, datos, $routeParams, $anchorScroll) {
        //console.log($routeParams);
        $scope.listaTabs = [{
                titulo: 'NOMs Vigentes',
                clave: 'vigente'
            }, {
                titulo: 'Proyectos de NOM',
                clave: 'proyecto'
            },
            /*{
                titulo: 'NOMs Canceladas',
                clave: 'cancelada'
            }
            */
        ];


        $scope.irComite = function irComite(comite, hash) {
            //console.log('Ir a comite: ' + comite);
            $location.path('/dependencia/' + comite);
            $location.hash(hash);
            $anchorScroll();
            //reset to old to keep any additional routing logic from kicking in

        };

        datos.getDependencias().then(function exito(resultado) {
            $scope.dependencias = resultado;
        }, function error(errorData) {
            $scope.dependencias = [];
            console.log('Error en getDependencias' + errorData);
        });

        $scope.accederNorma = function accederNorma(claveNOM) {
            //console.log('accederNorma' + claveNOM);
            $location.path('/nom/' + encodeURIComponent(claveNOM));
        };

        $scope.buscar = {};
        $scope.reiniciarFiltros = function reiniciarFiltros() {
            $scope.buscar = {};
            $scope.orden = '';
        };
        $scope.listadoNOMsActual = [];
        datos.getListadoNOMS().then(function(datos) {
            $scope.listadoNOMsActual = datos;
        });

        $scope.normaActual = {};

        $scope.equivalencias = {
            'NULL': {
                icono: 'cog',
                nombre: 'Sin categorizar',
                categoria: 'nulo'
            },
            'Proyecto Modificación': {
                icono: 'lab',
                nombre: 'Proyecto de modificación',
                categoria: 'proymod'
            },
            'Proyecto NOM': {
                icono: 'bulb',
                nombre: 'Proyecto de norma',
                categoria: 'proymnom'
            },
            'Otros Documentos': {
                icono: 'attachment',
                nombre: 'Otros',
                categoria: 'otros'
            },
            'NOM': {
                icono: 'note',
                nombre: 'Publicación de Norma',
                categoria: 'nom'
            },
            'Respuestas a Comentarios': {
                icono: 'bullhorn',
                nombre: 'Respuestas a comentarios',
                categoria: 'resp'
            },
            'Modificación': {
                icono: 'quill',
                nombre: 'Modicación',
                categoria: 'mod'
            },
            'Cancelación': {
                icono: 'cross',
                nombre: 'Cancelación',
                categoria: 'cancel'
            },
            'MIR Proyecto': {
                icono: 'briefcase',
                nombre: 'MIR',
                categoria: 'mir'
            },
            'MIR Otros': {
                icono: 'briefcase',
                nombre: 'MIR',
                categoria: 'mir'
            },
            'MIR Anteproyecto': {
                icono: 'briefcase',
                nombre: 'MIR',
                categoria: 'mir'
            },
            'MIR Proyecto Modificación': {
                icono: 'briefcase',
                nombre: 'MIR',
                categoria: 'mir'
            },
            'MIR Anteproyecto Modificación': {
                icono: 'briefcase',
                nombre: 'MIR',
                categoria: 'mir'
            },
            'MIR Modificación Acuerdo': {
                icono: 'briefcase',
                nombre: 'MIR',
                categoria: 'mir'
            }
        };
        $scope.seleccionaIcono = function selec(tipo) {
            return $scope.equivalencias[tipo].icono;


        };
        $scope.seleccionaCategoriaNOM = function selec(tipo) {
            return $scope.equivalencias[tipo].categoria;

        };
        $scope.seleccionaNombreNOM = function selec(tipo) {
            if (tipo) {
                return $scope.equivalencias[tipo].nombre;
            }

        };

        $scope.guionRex = /-/g;

        if ($routeParams.clave) {
            $scope.claveActual = decodeURIComponent($routeParams.clave);
            //console.log('NOM:  ' + $scope.claveActual);
            datos.getNOM($scope.claveActual).then(function(datos1) {
                $scope.normaActual = angular.fromJson(datos1);
                datos.getNOMgeneral($scope.claveActual).then(function(datos2) {
                    $scope.normaActualDetalle = datos2[0];
                    //console.log($scope.normaActualDetalle);
                });
            });
        } else {
            for (var llave in $routeParams) { //TODO - no me acuerdo que hace esto - creo que obtiene el key
                break;
            }


            if (llave) {
                $scope.seleccion = llave;
                $scope.seleccionFiltro = decodeURIComponent($routeParams[llave]);
                //console.log($scope.seleccionFiltro);

                $scope.listadoNOMsSeleccion = [];
                datos.getListadoNOMsSeleccion(llave, $scope.seleccionFiltro).then(function(datos) {
                    $scope.listadoNOMsSeleccion = datos;
                });
            }
        }



    });
