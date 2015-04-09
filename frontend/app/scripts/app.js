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
        'ui.select'
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
            .when('/dependencia/:siglas', {
                templateUrl: 'views/dependencia.html',
                controller: 'NormasCtrl'
            })
            .when('/glosario', {
                templateUrl: 'views/glosario.html',
                controller: 'NormasCtrl'
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
