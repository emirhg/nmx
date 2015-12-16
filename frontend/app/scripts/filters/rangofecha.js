'use strict';

/**
 * @ngdoc filter
 * @name frontendApp.filter:rangoFecha
 * @function
 * @description
 * # rangoFecha
 * Filter in the frontendApp.
 */
angular.module('frontendApp')
    .filter('rangoFecha', function() {
        return function(input, range) {
            var out = [];
            for (var i = input.length - 1; i >= 0; i--) {
                var año = input[i]['fecha_publicacion'].substring(0, 4);
                if (range.min <= año && año <= range.max) {
                    out.push(input[i]);
                }
            }
            return out;
        };
    });
