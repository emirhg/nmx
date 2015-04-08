'use strict';

describe('Controller: NormasCtrl', function () {

  // load the controller's module
  beforeEach(module('frontendApp'));

  var NormasCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    NormasCtrl = $controller('NormasCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
