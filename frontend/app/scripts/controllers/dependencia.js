'use strict';

/**
 * @ngdoc function
 * @name frontendApp.controller:DependenciaCtrl
 * @description
 * # DependenciaCtrl
 * Controller of the frontendApp
 */
angular.module('frontendApp')
    .controller('DependenciaCtrl', function($scope, $location, $routeParams, datos, $anchorScroll, socialShareImco) {

        $scope.accederNorma = function accederNorma(claveNOM) {
            console.log('accederNorma' + claveNOM);
            $location.path('/nom/' + encodeURIComponent(claveNOM));
        };
        $scope.dependenciaActual = {
            siglas: $routeParams.siglas,
        };
        datos.getFullDependencias($routeParams.siglas).then(function exito(resultado) {
            var totalNOMs = 0;
            for (var i = 0; i < resultado.length; i++) {
                totalNOMs += resultado[i].normas.length;
            }
            $scope.dependenciaActual.totalNOMs = totalNOMs;
            $scope.dependenciaActual.comites = resultado;

            $anchorScroll();
        }, function error(dataError) {
            $scope.dependenciaActula = {};
            console.log('Error en getFullDependencias' + dataError);
        });

        var facebookM = {
            capiton: "Todo sobre la norma"
        }
        var tweetM = {};
        $scope.tweet = function() {
            tweetM.text = 'Todas las NOMs de: ' + $scope.dependenciaActual.comites[0].nombre_dependencia + ', en';
            socialShareImco.tweet(tweetM);
        };
        $scope.facebook = function() {
            facebookM.capiton = 'Todas las NOMs de: ' + $scope.dependenciaActual.comites[0].nombre_dependencia + ', en';
            facebook.link = $location.absUrl();
            facebook.redirect_uri = $location.absUrl();
            socialShareImco.facebook(facebookM);
        };

        $scope.irComite = function irComite(comite) {
            console.log('Ir a comite: ' + comite);
            var old = $location.hash();
            $location.hash(comite);
            $anchorScroll();
            //reset to old to keep any additional routing logic from kicking in
            $location.hash(old);
        };
    });
