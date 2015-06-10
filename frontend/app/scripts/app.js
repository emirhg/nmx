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
        'ngTouch',
        'ui.bootstrap',
        'ui.select',
        'angular-loading-bar'
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
            .otherwise({
                redirectTo: '/'
            });
        uiSelectConfig.theme = 'select2';
    });
