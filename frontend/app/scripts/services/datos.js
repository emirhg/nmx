'use strict';

/**
 * @ngdoc factory
 * @name frontendApp.datos
 * @description
 * # datos
 * Service in the frontendApp.
 */
angular.module('frontendApp')
    .factory('datos', ['$http', '$q', 'utils', '$localStorage', function($http, $q, utils, $localStorage) {
        utils.imprimeIMCO('#0A809D');
        // Service logic
        // ...
        var normasVigentes = [];
        //var listadoNOMs = [];
        //var normasCanceladas = [];
        var proyectosNorma = [];
        //var NOMsConsultadas = {};

        //var baseurl = 'http://nomsapi.dev.imco.org.mx';
        var baseurl = 'http://apiv3.dev.imco.org.mx/catalogonoms';

        //NMX
        var nmxVigentes =   [];

        var getListadoNMX = function() {
            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            if (nmxVigentes.length > 0) {
                //console.log('Vigentes');
                deferred.resolve(nmxVigentes);
            } else {
                $http({
                        method: 'GET',
                        url: baseurl + '/nmx/vigentes',
                    })
                    .success(function(data) {
                        //console.log('GET Vigentes');
                        nmxVigentes = angular.copy(data);
                        //$localStorage.nmxVigentes = nmxVigentes;
                        return deferred.resolve(nmxVigentes);
                    })
                    .error(function(data) {
                        console.log('Error');
                        console.log(data);
                        deferred.reject(data);
                    });
            }
            return deferred.promise;
        };

        var getNMX = function(clave) {
            //console.log('NOM:' + claveNOM);

            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            $http({
                    method: 'GET',
                    url: baseurl + '/nmx/detalle/' + clave,
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

        var ctnns =   [];
        var getCTNN = function() {
            //console.log('NOM:' + claveNOM);

            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            if (ctnns.length > 0) {
                //console.log('Vigentes');
                deferred.resolve(ctnns);
            } else {
                $http({
                        method: 'GET',
                        url: baseurl + '/nmx/ctnn',
                    })
                    .success(function(data) {
                        //console.log('GET Vigentes');
                        ctnns = angular.copy(data);
                        $localStorage.ctnns = ctnns;
                        return deferred.resolve(ctnns);
                    })
                    .error(function(data) {
                        console.log('Error');
                        console.log(data);
                        deferred.reject(data);
                    });
            }
            return deferred.promise;
        };

        var getFullCTNN = function(slug_ctnn) {
            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            $http({
                    method: 'GET',
                    url: baseurl + '/nmx/vigentes/byctnn/' + slug_ctnn,
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

        // var onn = $localStorage.onn ||  [];
        var onn =   [];
        var getOrganismo = function() {
            //console.log('NOM:' + claveNOM);

            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            if (onn.length > 0) {
                //console.log('Vigentes');
                deferred.resolve(onn);
            } else {
                $http({
                        method: 'GET',
                        url: baseurl + '/nmx/onn',
                    })
                    .success(function(data) {
                        //console.log('GET Vigentes');
                        onn = angular.copy(data);
                        $localStorage.onn = onn;
                        return deferred.resolve(onn);
                    })
                    .error(function(data) {
                        console.log('Error');
                        console.log(data);
                        deferred.reject(data);
                    });
            }
            return deferred.promise;
        };

        var getFullOrganismo = function(slug_ctnn) {
            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            $http({
                    method: 'GET',
                    url: baseurl + '/nmx/vigentes/byonn/' + slug_ctnn,
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
        var getFullKeyWord = function(keyword) {
            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            $http({
                    method: 'GET',
                    url: baseurl + '/nmx/vigentes/bykeyword/' + keyword,
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

        var keywords =   [];
        var getKeywords = function() {
            //console.log('NOM:' + claveNOM);

            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            if (keywords.length > 0) {
                //console.log('Vigentes');
                deferred.resolve(keywords);
            } else {
                $http({
                        method: 'GET',
                        url: baseurl + '/nmx/keywords',
                    })
                    .success(function(data) {
                        //console.log('GET Vigentes');
                        keywords = angular.copy(data);
                        $localStorage.keywords = keywords;
                        return deferred.resolve(keywords);
                    })
                    .error(function(data) {
                        console.log('Error');
                        console.log(data);
                        deferred.reject(data);
                    });
            }
            return deferred.promise;
        };

        var getFullRama = function(rama) {
            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            $http({
                    method: 'GET',
                    url: baseurl + '/nmx/vigentes/byramaeconomica/' + rama,
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

        var ramas =   [];
        var getRamas = function() {
            //console.log('NOM:' + claveNOM);

            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            if (ramas.length > 0) {
                //console.log('Vigentes');
                deferred.resolve(ramas);
            } else {
                $http({
                        method: 'GET',
                        url: baseurl + '/nmx/ramas',
                    })
                    .success(function(data) {
                        //console.log('GET Vigentes');
                        ramas = angular.copy(data);
                        $localStorage.ramas = ramas;
                        return deferred.resolve(ramas);
                    })
                    .error(function(data) {
                        console.log('Error');
                        console.log(data);
                        deferred.reject(data);
                    });
            }
            return deferred.promise;
        };


        var getListadoNOMS = function() {
            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            if (normasVigentes.length > 0) {
                //console.log('Vigentes');
                deferred.resolve(normasVigentes);
            } else {
                $http({
                        method: 'GET',
                        url: baseurl + '/noms',
                    })
                    .success(function(data) {
                        //console.log('GET Vigentes');
                        normasVigentes = angular.copy(data);
                        return deferred.resolve(normasVigentes);
                    })
                    .error(function(data) {
                        console.log('Error');
                        console.log(data);
                        deferred.reject(data);
                    });
            }
            return deferred.promise;
        };

        var getListadoProyectoNOMS = function() {
            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            if (proyectosNorma.length > 0) {
                //console.log('Proyectos');
                deferred.resolve(proyectosNorma);
            } else {

                $http({
                        method: 'GET',
                        //url: 'scripts/datos/todasNOMsTest.json',
                        url: baseurl + '/proyecto',
                    })
                    .success(function(data) {
                        //console.log('GET Proyectos');
                        proyectosNorma = angular.copy(data);
                        return deferred.resolve(proyectosNorma);
                    })
                    .error(function(data) {
                        console.log('Error');
                        console.log(data);
                        deferred.reject(data);
                    });
            }
            return deferred.promise;

        };

        var getListadoNOMsSeleccion = function(llave, seleccion) {
            //Obtener el listado de noms con un tamaño de venta y con un offset que representa el 
            var deferred = $q.defer();
            // Resolve the deferred $q object before returning the promise
            $http({
                    method: 'GET',
                    url: baseurl + '/' + llave + '/' + seleccion,
                })
                .success(function(data) {
                    //normasVigentes = angular.copy(data);
                    deferred.resolve(data);
                })
                .error(function(data) {
                    console.log('Error');
                    console.log(data);
                    deferred.reject(data);
                });

            return deferred.promise;

        }; //TODO


        var getNOM = function(claveNOM) {
            //console.log('NOM:' + claveNOM);

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
            //console.log('NOM:' + claveNOM);

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
            //console.log('getDependencias..');
            var deferred = $q.defer();

            $http({
                method: 'GET',
                url: baseurl + '/dependencia',
            }).success(function(data) {
                dependencias = angular.fromJson(data);
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
        var fullDependencias = {};
        var getFullDependencias = function getDependencias(dependencia) {
            //console.log('getDependencias..');
            var deferred = $q.defer();
            $http({
                method: 'GET',
                url: baseurl + '/dependencia/' + encodeURIComponent(dependencia),
            }).success(function(data) {
                fullDependencias[dependencia] = angular.fromJson(data);
                if (dependencias.lenght !== 0) {
                    deferred.resolve(fullDependencias[dependencia]);
                } else {
                    deferred.reject(fullDependencias[dependencia]);
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
            //console.log('getProductos..');
            var deferred = $q.defer();

            $http({
                method: 'GET',
                url: baseurl + '/producto',
            }).success(function(data) {
                productos = angular.fromJson(data[0].producto);
                //console.log(productos);
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

        var ramasEc = [];
        var getRamasEc = function getRamas() {
            //console.log('getRamas..');
            var deferred = $q.defer();

            $http({
                method: 'GET',
                url: baseurl + '/rama',
            }).success(function(data) {
                ramas = angular.fromJson(data[0].rama);
                //console.log(ramas);
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
            getFullRama: getFullRama,
            getRamas: getRamas,
            getFullDependencias: getFullDependencias,
            getListadoNOMsSeleccion: getListadoNOMsSeleccion,
            getListadoProyectoNOMS: getListadoProyectoNOMS,
            //NMX
            getListadoNMX: getListadoNMX,
            getNMX: getNMX,
            getCTNN: getCTNN,
            getFullCTNN: getFullCTNN,
            getKeywords: getKeywords,
            getFullKeyWord: getFullKeyWord,
            getOrganismo: getOrganismo,
            getFullOrganismo: getFullOrganismo,
            getRamasEc: getRamasEc
        };

    }]);
