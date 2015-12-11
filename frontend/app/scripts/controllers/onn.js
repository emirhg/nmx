'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:OnnCtrl
 * @description
 * # OnnCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('OnnCtrl', function($scope, datos, $location, $routeParams, socialShareImco) {

        datos.getFullOrganismo($routeParams.ctnn_slug).then(function exito(resultado) {
            console.debug($routeParams.onn_slug, resultado);
            $scope.onnActual = resultado;

        }, function error(dataError) {
            $scope.onnActual = {};
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
            tweetM.text = 'Todas las NMXs de: ' + $scope.onnActual[0].onn + ', en';
            socialShareImco.tweet(tweetM);
        };
        $scope.facebook = function() {
            facebookM.capiton = 'Todas las NMXs de: ' + $scope.onnActual[0].onn + ', en';
            facebookM.link = $location.absUrl();
            facebookM.redirect_uri = $location.absUrl();
            socialShareImco.facebook(facebookM);
        };
    });
