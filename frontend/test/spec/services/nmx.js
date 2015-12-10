'use strict';

describe('Service: nmx', function () {

  // load the service's module
  beforeEach(module('frontendApp'));

  // instantiate service
  var nmx;
  beforeEach(inject(function (_nmx_) {
    nmx = _nmx_;
  }));

  it('should do something', function () {
    expect(!!nmx).toBe(true);
  });

});
