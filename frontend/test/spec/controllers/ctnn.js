'use strict';

describe('Controller: CtnnCtrl', function () {

  // load the controller's module
  beforeEach(module('frontendApp'));

  var CtnnCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    CtnnCtrl = $controller('CtnnCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
