'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:CtnnCtrl
 * @description
 * # CtnnCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('CtnnCtrl', function($scope, datos, $location, $routeParams, socialShareImco) {

        datos.getFullCTNN($routeParams.ctnn_slug).then(function exito(resultado) {
            console.debug($routeParams.ctnn_slug, resultado);
            $scope.ctnnActual = resultado;

        }, function error(dataError) {
            $scope.ctnnActual = {};
            console.log('Error en getFullDependencias' + dataError);
        });

        $scope.accederNorma = function accederNorma(claveNOM) {
            console.log('accederNorma' + claveNOM);
            $location.path('/nmx/' + encodeURIComponent(claveNOM));
        };

        var facebookM = {
            capiton: "Todo sobre la norma"
        }
        var tweetM = {};
        $scope.tweet = function() {
            tweetM.text = 'Todas las NMXs de: ' + $scope.ctnnActual[0].ctnn + ', en';
            socialShareImco.tweet(tweetM);
        };
        $scope.facebook = function() {
            facebookM.capiton = 'Todas las NMXs de: ' + $scope.ctnnActual[0].ctnn + ', en';
            facebookM.link = $location.absUrl();
            facebookM.redirect_uri = $location.absUrl();
            socialShareImco.facebook(facebookM);
        };
    });
