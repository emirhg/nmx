'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:ProyectosCtrl
 * @description
 * # ProyectosCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('ProyectosCtrl', function($scope, datos) {
        datos.getListadoProyectoNOMS().then(function(datos) {
            $scope.proyectos = datos;
            console.log($scope.proyectos);
        });
    });
