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
			link: '/',
			titulo: 'Inicio',
			activo: true
		}, {
			link: '/#',
			titulo: 'NOMs'
		}, {
			link: '/',
			titulo: 'Glosario'
		}, {
			link: '/',
			titulo: 'Proyectos NOMs'
		}, {
			link: '/',
			titulo: 'Contacto'
		}, ];
	});