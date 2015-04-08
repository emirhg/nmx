'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('MainCtrl', function($scope) {
        $scope.clear = function() {
            $scope.person.selected = undefined;
            $scope.address.selected = undefined;
            $scope.country.selected = undefined;
        };

        $scope.person = {};
        $scope.people = [{
            name: 'Adam',
            email: 'adam@email.com',
            age: 10
        }, {
            name: 'Amalie',
            email: 'amalie@email.com',
            age: 12
        }, {
            name: 'Wladimir',
            email: 'wladimir@email.com',
            age: 30
        }, {
            name: 'Samantha',
            email: 'samantha@email.com',
            age: 31
        }, {
            name: 'Estefanía',
            email: 'estefanía@email.com',
            age: 16
        }, {
            name: 'Natasha',
            email: 'natasha@email.com',
            age: 54
        }, {
            name: 'Nicole',
            email: 'nicole@email.com',
            age: 43
        }, {
            name: 'Adrian',
            email: 'adrian@email.com',
            age: 21
        }];

    });
