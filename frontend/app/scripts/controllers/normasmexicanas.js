'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:NormasmexicanasCtrl
 * @description
 * # NormasmexicanasCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('NormasmexicanasCtrl', function($scope, datos) {
        $scope.listadoNMXsActual = [];
        datos.getListadoNMX().then(function(result) {
            console.warn(result);
            $scope.listadoNMXsActual = result;
        });

        $scope.accederNorma = function accederNorma(claveNOM) {
            //console.log('accederNorma' + claveNOM);
            $location.path('/nom/' + encodeURIComponent(claveNOM));
        };

    });
