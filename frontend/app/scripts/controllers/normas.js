'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:NormasCtrl
 * @description
 * # NormasCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
	.controller('NormasCtrl', function($scope, $location, datos, $routeParams) {
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
		$scope.accederNorma = function accederNorma(claveNOM) {
			console.log('accederNorma' + claveNOM);
			$location.path('/nom/' + claveNOM);
		};
		$scope.listadoNOMsActual = [];
		datos.getListadoNOMS().then(function(datos) {
			$scope.listadoNOMsActual = datos;
		});
		$scope.normaActual = {};

		$scope.equivalencias = {
			'NULL': {
				icono: 'cog',
				nombre: 'Sin categorizar',
				categoria: 'nulo'
			},
			'PROY Modificación': {
				icono: 'lab',
				nombre: 'Proyecto de modificación',
				categoria: 'proymod'
			},
			'PROY NOM': {
				icono: 'bulb',
				nombre: 'Proyecto de norma',
				categoria: 'proymnom'
			},
			'Otros Documentos': {
				icono: 'attachment',
				nombre: 'Otros',
				categoria: 'otros'
			},
			'NOM': {
				icono: 'note',
				nombre: 'Publicación de Norma',
				categoria: 'nom'
			},
			'Respuestas': {
				icono: 'bullhorn',
				nombre: 'Respuestas a los comentarios',
				categoria: 'resp'
			},
			'Modificación': {
				icono: 'quill',
				nombre: 'Modicación',
				categoria: 'mod'
			}
		};
		$scope.seleccionaIcono = function selec(tipo) {
			return $scope.equivalencias[tipo].icono;


		};
		$scope.seleccionaCategoriaNOM = function selec(tipo) {
			return $scope.equivalencias[tipo].categoria;

		};

		$scope.guionRex = /-/g;

		if ($routeParams.clave) {
			datos.getNOM($routeParams.clave).then(function(datos) {
				$scope.normaActual = datos;
			});
		}
	});