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
    'ui.bootstrap'
  ])
  .config(function ($routeProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/normas.html',
        controller: 'NormasCtrl'
      })
      .when('/nom/:clave', {
        templateUrl: 'views/norma.html',
        controller: 'NormasCtrl'
      })
      .otherwise({
        redirectTo: '/'
      });
  });
