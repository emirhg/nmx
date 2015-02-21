'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:NormasCtrl
 * @description
 * # NormasCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
	.controller('NormasCtrl', function($scope,$location) {
		$scope.listaTabs = [{
			titulo: 'NOMs Vigentes',
			clave: 'vigente'
		}, {
			titulo: 'Proyectos de NOM',
			clave: 'proyecto'
		}, {
			titulo: 'NOMs Canceladas',
			clave: 'cancelada'
		}];
		$scope.accederNorma =function accederNorma (claveNOM) {
			console.log('accederNorma' + claveNOM);
			$location.path('/nom/'+claveNOM);
		};
	});