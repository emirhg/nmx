'use strict';

/**
 * @ngdoc overview
 * @name frontendApp
 * @description
 * # frontendApp
 *
 * Main module of the application.
 */
angular
    .module('frontendApp', [
        'ngAnimate',
        'ngCookies',
        'ngResource',
        'ngRoute',
        'ngSanitize',
        'ngStorage',
        'rzModule',
        'ngTouch',
        'ui.bootstrap',
        'ui.select',
        'angular-loading-bar',
        'imco',
        'ngDonutsD3'
    ])
    .config(function($routeProvider, uiSelectConfig) {
        $routeProvider
            .when('/', {
                templateUrl: 'views/principal.html',
                controller: 'MainCtrl'
            })
            .when('/noms', {
                templateUrl: 'views/normas.html',
                controller: 'NormasCtrl'
            })
            .when('/nmx', {
                templateUrl: 'views/normas_mexicanas.html',
                controller: 'NormasmexicanasCtrl'
            })
            .when('/ctnn/:ctnn_slug', {
                templateUrl: 'views/ctnn.html',
                controller: 'CtnnCtrl'
            })
            .when('/nmx/:clave', {
                templateUrl: 'views/norma_mexicana.html',
                controller: 'NormasmexicanasCtrl'
            })
            .when('/proyectos_nom', {
                templateUrl: 'views/proyectos.html',
                controller: 'ProyectosCtrl'
            })
            .when('/noms/:seleccion', {
                templateUrl: 'views/normas.html',
                controller: 'NormasCtrl'
            })
            .when('/dependencia/:siglas', {
                templateUrl: 'views/dependencia.html',
                controller: 'DependenciaCtrl'
            })
            .when('/glosario', {
                templateUrl: 'views/glosario.html',
                controller: 'NormasCtrl'
            })
            .when('/contacto', {
                templateUrl: 'views/contacto.html',
                controller: 'NormasCtrl'
            })
            .when('/proceso', {
                templateUrl: 'views/proceso.html',
                controller: 'MainCtrl'
            })
            .when('/metodologia', {
                templateUrl: 'views/metodologia.html',
                controller: 'MainCtrl'
            })
            .when('/nom/:clave', {
                templateUrl: 'views/norma.html',
                controller: 'NormasCtrl'
            })
            .when('/test', {
                templateUrl: 'views/test.html',
                controller: 'NormasCtrl'
            })
            .otherwise({
                redirectTo: '/'
            });
        uiSelectConfig.theme = 'select2';
    });
