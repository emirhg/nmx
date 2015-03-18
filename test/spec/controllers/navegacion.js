'use strict';

describe('Controller: NavegacionCtrl', function () {

  // load the controller's module
  beforeEach(module('frontendApp'));

  var NavegacionCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    NavegacionCtrl = $controller('NavegacionCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
