'use strict';

describe('Filter: rangoFecha', function () {

  // load the filter's module
  beforeEach(module('frontendApp'));

  // initialize a new instance of the filter before each test
  var rangoFecha;
  beforeEach(inject(function ($filter) {
    rangoFecha = $filter('rangoFecha');
  }));

  it('should return the input prefixed with "rangoFecha filter:"', function () {
    var text = 'angularjs';
    expect(rangoFecha(text)).toBe('rangoFecha filter: ' + text);
  });

});
