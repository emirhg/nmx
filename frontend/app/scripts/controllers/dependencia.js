'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:DependenciaCtrl
 * @description
 * # DependenciaCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('DependenciaCtrl', function($scope, $location, $routeParams, datos, $anchorScroll) {

        $scope.accederNorma = function accederNorma(claveNOM) {
            console.log('accederNorma' + claveNOM);
            $location.path('/nom/' + encodeURIComponent(claveNOM));
        };
        $scope.dependenciaActual = {
            siglas: $routeParams.siglas,
        };
        datos.getFullDependencias($routeParams.siglas).then(function exito(resultado) {
            $scope.dependenciaActual.comites = resultado;
            $anchorScroll();
        }, function error(error) {
            $scope.dependenciaActula = {};
            console.log('Error en getFullDependencias');
        });

        $scope.irComite = function irComite(comite) {
            console.log('Ir a comite: ' + comite);
            var old = $location.hash();
            $location.hash(comite);
            $anchorScroll();
            //reset to old to keep any additional routing logic from kicking in
            $location.hash(old);
        }
    });
