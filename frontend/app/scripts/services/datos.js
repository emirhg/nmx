'use strict';

/**
 * @ngdoc factory
 * @name frontendApp.datos
 * @description
 * # datos
 * Service in the frontendApp.
 */
angular.module('frontendApp')
    .factory('datos', function($http, $q) {
        // Service logic
        // ...
        var normasVigentes = [];
        var listadoNOMs = [];
        var normasCanceladas = [];
        var proyectosNorma = [];
        var NOMsConsultadas = {};

        //var baseurl = 'http://backend.noms';
        var baseurl = 'http://nomsapi.dev.imco.org.mx';


        var getListadoNOMS = function(tamVentana, offsetVentana) {
            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            if (normasVigentes.lenght > 0) {
                console.log('Vigentes');
                deferred.resolve(normasVigentes);
            } else {

                $http({
                        method: 'GET',
                        //url: 'scripts/datos/todasNOMsTest.json',
                        url: baseurl + '/noms',
                    })
                    .success(function(data) {
                        normasVigentes = angular.copy(data);
                        return deferred.resolve(data);
                    })
                    .error(function(data) {
                        console.log('Error');
                        console.log(data);
                        deferred.reject(data);
                    });
            }
            return deferred.promise;

        };
        var getNOM = function(claveNOM) {
            console.log('NOM:' + claveNOM);

            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            $http({
                    method: 'GET',
                    url: baseurl + '/nom/' + claveNOM,
                })
                .success(function(data) {
                    return deferred.resolve(data);
                })
                .error(function(data) {
                    console.log('Error');
                    console.log(data);
                    deferred.reject(data);
                });
            return deferred.promise;

        };
        var getNOMgeneral = function(claveNOM) {
            console.log('NOM:' + claveNOM);

            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            $http({
                    method: 'GET',
                    url: baseurl + '/noms/' + claveNOM,
                })
                .success(function(data) {
                    return deferred.resolve(data);
                })
                .error(function(data) {
                    console.log('Error');
                    console.log(data);
                    deferred.reject(data);
                });
            return deferred.promise;

        };
        var dependencias = [];
        var getDependencias = function getDependencias() {
            console.log('getDependencias..');
            var deferred = $q.defer();

            $http({
                method: 'GET',
                url: baseurl + '/dependencia',
            }).success(function(data) {
                dependencias = angular.fromJson(data);
                console.log(dependencias);
                if (dependencias.lenght !== 0) {
                    deferred.resolve(dependencias);
                } else {
                    deferred.reject(dependencias);
                }
            }).error(function(data) {
                console.log('Error');
                console.log(data);
                deferred.reject(data);
            });

            return deferred.promise;
        };
        var productos = [];
        var getProductos = function getProductos() {
            console.log('getProductos..');
            var deferred = $q.defer();

            $http({
                method: 'GET',
                url: baseurl + '/producto',
            }).success(function(data) {
                productos = angular.fromJson(data[0].producto);
                console.log(productos);
                if (productos.lenght !== 0) {
                    deferred.resolve(productos);
                } else {
                    deferred.reject(productos);
                }
            }).error(function(data) {
                console.log('Error');
                console.log(data);
                deferred.reject(data);
            });

            return deferred.promise;
        };

        var ramas = [];
        var getRamas = function getRamas() {
            console.log('getRamas..');
            var deferred = $q.defer();

            $http({
                method: 'GET',
                url: baseurl + '/rama',
            }).success(function(data) {
                ramas = angular.fromJson(data[0].rama);
                console.log(ramas);
                if (ramas.lenght !== 0) {
                    deferred.resolve(ramas);
                } else {
                    deferred.reject(ramas);
                }
            }).error(function(data) {
                console.log('Error');
                console.log(data);
                deferred.reject(data);
            });

            return deferred.promise;
        };


        return {
            getListadoNOMS: getListadoNOMS,
            getNOM: getNOM,
            getNOMgeneral: getNOMgeneral,
            getDependencias: getDependencias,
            getProductos: getProductos,
            getRamas: getRamas,
        };

    });
