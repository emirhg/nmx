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
            link: '#/noms',
            titulo: 'NOMs'
        }, {
            link: '#/glosario',
            titulo: 'Glosario'
        }, {
            link: '#/proyectos_nom',
            titulo: 'Proyectos NOMs'
        }, {
            link: '#/proceso',
            titulo: '¿Cómo se hacen las NOMs?'
        }, {
            link: '#/metodologia',
            titulo: 'Metodología'
        }, {
            link: '#/contacto',
            titulo: 'Contacto'
        }, ];
    });
