'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:NormasmexicanasCtrl
 * @description
 * # NormasmexicanasCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('NormasmexicanasCtrl', function($scope, $location, datos, $routeParams) {
        $scope.listadoNMXsActual = [];
        $scope.buscar = {};
        $scope.resultados = 150;
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
        datos.getCTNN().then(function(result) {
            $scope.ctnns = result;
        })

        if ($routeParams.clave) {
            $scope.claveActual = decodeURIComponent($routeParams.clave);
            datos.getNMX($scope.claveActual).then(function(datos1) {
                $scope.normaActual = datos1;
                console.log('NOM:  ', datos1);

            });
        }

        $scope.accederNorma = function accederNorma(claveNOM) {
            //console.log('accederNorma' + claveNOM);
            $location.path('/nmx/' + encodeURIComponent(claveNOM));
        };

    });
