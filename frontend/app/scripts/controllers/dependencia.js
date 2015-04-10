'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:DependenciaCtrl
 * @description
 * # DependenciaCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('DependenciaCtrl', function($scope, $routeParams, datos) {
        $scope.dependenciaActual = {
            siglas: $routeParams.siglas,
        };
        datos.getFullDependencias($routeParams.siglas).then(function exito(resultado) {
            $scope.dependenciaActual.comites = resultado;
        }, function error(error) {
            $scope.dependenciaActula = {};
            console.log('Error en getFullDependencias');
        });
    });
