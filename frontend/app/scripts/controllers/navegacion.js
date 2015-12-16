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
            link: 'http://noms.imco.org.mx/#/',
            titulo: 'NOMs'
        }, {
            link: 'http://nmx.imco.org.mx/#/',
            titulo: 'NMXs'
        }, {
            link: '#/glosario',
            titulo: 'Otras Normas'
        }];
    });
