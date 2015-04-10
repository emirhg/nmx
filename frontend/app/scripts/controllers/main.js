'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('MainCtrl', function($scope, datos, $location) {
        $scope.clear = function() {
            $scope.person.selected = undefined;
            $scope.address.selected = undefined;
            $scope.country.selected = undefined;
        };

        console.log(datos.getDependencias());
        datos.getDependencias().then(function exito(resultado) {
            $scope.dependencias = resultado;
        }, function error(argument) {
            $scope.dependencias = [];
            console.log('Error en getDependencias');
        });

        datos.getProductos().then(function exito(resultado) {
            $scope.productos = resultado;
        }, function error(argument) {
            $scope.productos = [];
            console.log('Error en getProductos');
        })
        datos.getRamas().then(function exito(resultado) {
            $scope.ramas = resultado;
        }, function error(argument) {
            $scope.ramas = [];
            console.log('Error en getRamas');
        });

        $scope.vistaDependencia = function vistaDependencia(index, dependencia) {
            console.log('Ir a dependencia: ' + index + ' ' + dependencia);
            $location.path('/dependencia/' + dependencia);
        };
        $scope.seleccion = {
            rama: '',
            producto: ''
        };

        $scope.filtraRama = function filtraRama(cualSeleccion) {
            console.log('Ir a seleccion: ' + cualSeleccion + ' ' + $scope.seleccion[cualSeleccion]);

            if ($scope.seleccion[cualSeleccion]) {
                console.log('Ir a seleccion: ' + cualSeleccion + ' ' + $scope.seleccion[cualSeleccion]);
                var search = {};
                search[cualSeleccion] = encodeURIComponent($scope.seleccion[cualSeleccion]);
                $location.path('/noms').search(search);
            }

        };





    });
