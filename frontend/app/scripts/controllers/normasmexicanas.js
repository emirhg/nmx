'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:NormasmexicanasCtrl
 * @description
 * # NormasmexicanasCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('NormasmexicanasCtrl', function($scope, $location, datos, $routeParams, socialShareImco) {
        $scope.listadoNMXsActual = [];
        $scope.buscar = {};
        $scope.resultados = 150;

        datos.getCTNN().then(function(result) {
            $scope.ctnns = result;
        })
        $scope.res = {
            min: 1980,
            max: 2020
        };
        $scope.slider2 = {
            min: 1980,
            max: 2020,
            options: {
                floor: 1950,
                ceil: 2020,
                step: 10,
                draggableRange: true,
                showTicksValues: true
            },
            onEnd: function() {
                $scope.res = {
                    min: $scope.slider.min,
                    max: $scope.slider.max
                };
            }
        };

        $scope.reiniciarFiltros = function reiniciarFiltros() {
            $scope.buscar = {};
            $scope.orden = '';
        };

        if ($routeParams.clave) {
            $scope.claveActual = decodeURIComponent($routeParams.clave);
            datos.getNMX($scope.claveActual).then(function(datos1) {
                $scope.normaActual = datos1;
                console.log('NOM:  ', datos1);

            });
        } else if ($routeParams.keyword) {
            $scope.listadoNMXsActual = [];
            $scope.keyword = decodeURIComponent($routeParams.keyword);
            datos.getFullKeyWord($scope.keyword).then(function(datos) {
                $scope.listadoNMXsActual = $scope.listadoNMXsActual.concat(datos);
                $scope.resultados = datos.length;
                console.debug('keyword', datos);
            });
            datos.getFullRama($scope.keyword).then(function(datos) {
                $scope.listadoNMXsActual = $scope.listadoNMXsActual.concat(datos);

                $scope.resultados = $scope.listadoNMXsActual.length;
                console.debug('rama', datos);

            });
        } else {
            datos.getListadoNMX().then(function(result) {
                console.warn(result);
                $scope.listadoNMXsActual = result;
                $scope.slider = {
                    value: 150,
                    options: {
                        floor: 0,
                        ceil: result.length
                    },
                    onEnd: function() {
                        $scope.resultados = $scope.slider.value;
                    }
                };
            });
        }



        $scope.accederNorma = function accederNorma(claveNOM) {
            //console.log('accederNorma' + claveNOM);
            $location.path('/nmx/' + encodeURIComponent(claveNOM));
        };
        $scope.irONN = function(clave) {
            //console.log('accederNorma' + claveNOM);
            $location.path('/onn/' + encodeURIComponent(clave));
        };
        $scope.irCTNN = function(clave) {
            //console.log('accederNorma' + claveNOM);
            $location.path('/ctnn/' + encodeURIComponent(clave));
        };

        var facebookM = {
            capiton: 'Todo sobre la norma',


        };

        var tweetM = {};
        $scope.tweet = function() {
            tweetM.text = 'Todo sobre la norma: ' + $scope.claveActual + ', en';
            socialShareImco.tweet(tweetM);
        };
        $scope.facebook = function() {
            facebookM.capiton = 'Todo sobre la norma: ' + $scope.claveActual + ', en';
            facebookM.link = $location.absUrl();
            facebookM.redirect_uri = $location.absUrl();
            socialShareImco.facebook(facebookM);
        };


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
            'Vigencia': {
                icono: 'note',
                nombre: 'Declaratoria de vigencia',
                categoria: 'mod'
            },
            'Fe de erratas': {
                icono: 'zoom',
                nombre: 'Fe de erratas',
                categoria: 'erratas'
            },
            'Respuestas a Comentarios': {
                icono: 'bullhorn',
                nombre: 'Respuestas a comentarios',
                categoria: 'resp'
            },
            'Modificación': {
                icono: 'quill',
                nombre: 'Modificación',
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


    });
