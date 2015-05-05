'use strict';

describe('Controller: ProyectosCtrl', function () {

  // load the controller's module
  beforeEach(module('frontendApp'));

  var ProyectosCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ProyectosCtrl = $controller('ProyectosCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
