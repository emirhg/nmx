'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:NormasCtrl
 * @description
 * # NormasCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('NormasCtrl', function($scope, $location, datos, $routeParams) {
        console.log($routeParams);
        $scope.listaTabs = [{
            titulo: 'NOMs Vigentes',
            clave: 'vigente'
        }, {
            titulo: 'Proyectos de NOM',
            clave: 'proyecto'
        }, /*{
    titulo: 'NOMs Canceladas',
    clave: 'cancelada'
}
*/];

        datos.getDependencias().then(function exito(resultado) {
            $scope.dependencias = resultado;
        }, function error(argument) {
            $scope.dependencias = [];
            console.log('Error en getDependencias');
        });

        $scope.accederNorma = function accederNorma(claveNOM) {
            console.log('accederNorma' + claveNOM);
            $location.path('/nom/' + encodeURIComponent(claveNOM));
        };

        $scope.buscar = {};
        $scope.reiniciarFiltros = function reiniciarFiltros() {
            $scope.buscar = {};
            $scope.orden = '';
        }
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
            }
        };
        $scope.seleccionaIcono = function selec(tipo) {
            return $scope.equivalencias[tipo].icono;


        };
        $scope.seleccionaCategoriaNOM = function selec(tipo) {
            return $scope.equivalencias[tipo].categoria;

        };
        $scope.seleccionaNombreNOM = function selec(tipo) {
            return $scope.equivalencias[tipo].nombre;

        };

        $scope.guionRex = /-/g;

        if ($routeParams.clave) {
            $scope.claveActual = decodeURIComponent($routeParams.clave);
            datos.getNOM($routeParams.clave).then(function(datos1) {
                $scope.normaActual = datos1;
                datos.getNOMgeneral($routeParams.clave).then(function(datos2) {
                    $scope.normaActualDetalle = datos2[0];
                });
            });
        } else {
            for (var llave in $routeParams) break;
            console.log(llave);

            if (llave) {
                $scope.seleccion = llave;
                $scope.seleccionFiltro = decodeURIComponent($routeParams[llave]);
                console.log($scope.seleccionFiltro);

                $scope.listadoNOMsSeleccion = [];
                datos.getListadoNOMsSeleccion(llave, $routeParams[llave]).then(function(datos) {
                    $scope.listadoNOMsSeleccion = datos;
                });
            }
        }



    });
