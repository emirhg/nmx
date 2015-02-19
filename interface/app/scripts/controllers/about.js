'use strict';

/**
 * @ngdoc function
 * @name interfaceApp.controller:AboutCtrl
 * @description
 * # AboutCtrl
 * Controller of the interfaceApp
 */
angular.module('interfaceApp')
  .controller('AboutCtrl', function ($scope) {
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];
  });
