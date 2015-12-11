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

        datos.getCTNN().then(function exito(resultado) {
            $scope.cttns = resultado;
            console.log('ctnn', resultado);
        }, function error(errorData) {
            $scope.cttns = [];
            console.log('Error en getDependencias' + errorData);
        });
        datos.getOrganismo().then(function exito(resultado) {
            $scope.onns = resultado;
            console.log('onn', resultado);
        }, function error(errorData) {
            console.log('onn', errorData);

            $scope.onns = [];
            console.log('Error en getDependencias' + errorData);
        });
        datos.getKeywords().then(function exito(resultado) {
            $scope.keywords = resultado;
            console.log('keywords', resultado);
        }, function error(errorData) {
            $scope.keywords = [];
            console.log('Error en getDependencias' + errorData);
        });
        $scope.seleccion = {};
        $scope.vistaCTNN = function vistaDependencia(ctnn) {
            //console.log('Ir a dependencia: ' + index + ' ' + dependencia);
            $location.path('/ctnn/' + ctnn.ctnn_slug);
        };
        $scope.vistaOrganismo = function vistaDependencia(onn) {
            //console.log('Ir a dependencia: ' + index + ' ' + dependencia);
            $location.path('/onn/' + onn.onn_slug);
        };
        $scope.vistaKeyWord = function vistaDependencia(keyword) {
            //console.log('Ir a dependencia: ' + index + ' ' + dependencia);
            $location.path('/busqueda/' + keyword.keyword);
        };

        /*     datos.getDependencias().then(function exito(resultado) {
                 $scope.dependencias = resultado;
             }, function error(errorData) {
                 $scope.dependencias = [];
                 console.log('Error en getDependencias' + errorData);
             });

             datos.getProductos().then(function exito(resultado) {
                 $scope.productos = resultado;
             }, function error(errorData) {
                 $scope.productos = [];
                 console.log('Error en getProductos' + errorData);
             });

             datos.getRamas().then(function exito(resultado) {
                 $scope.ramas = resultado;
             }, function error(errorData) {
                 $scope.ramas = [];
                 console.log('Error en getRamas' + errorData);
             });

             $scope.vistaDependencia = function vistaDependencia(index, dependencia) {
                 //console.log('Ir a dependencia: ' + index + ' ' + dependencia);
                 $location.path('/dependencia/' + dependencia);
             };
             $scope.seleccion = {
                 rama: '',
                 producto: ''
             };

             $scope.filtraRama = function filtraRama(cualSeleccion) {
                 //console.log('Ir a seleccion: ' + cualSeleccion + ' ' + $scope.seleccion[cualSeleccion]);
                 if ($scope.seleccion[cualSeleccion]) {
                     //console.log('Ir a seleccion: ' + cualSeleccion + ' ' + $scope.seleccion[cualSeleccion]);
                     var search = {};
                     search[cualSeleccion] = encodeURIComponent($scope.seleccion[cualSeleccion]);
                     $location.path('/noms').search(search);
                 }

             };
             */
    });
