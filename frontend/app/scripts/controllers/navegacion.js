'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:NavegacionCtrl
 * @description
 * # NavegacionCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('NavegacionCtrl', function($scope) {
        $scope.listaPaginas = [{
            link: '#/',
            titulo: 'Inicio',
            activo: true
        }, {
            link: '#/nmx',
            titulo: 'NMXs'
        }];
    });
