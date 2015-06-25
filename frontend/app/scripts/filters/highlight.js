'use strict';

/**
 * @ngdoc filter
 * @name frontendApp.filter:highlight
 * @function
 * @description
 * # highlight
 * Filter in the frontendApp.
 */
angular.module('frontendApp')
    .filter('highlight', function($sce) {
        return function(text, phrase) {
            if (phrase) {
                text = text.replace(new RegExp('(' + phrase + ')', 'gi'), '<span class="highlighted">$1</span>');
            }
            return $sce.trustAsHtml(text);
        };
    });
