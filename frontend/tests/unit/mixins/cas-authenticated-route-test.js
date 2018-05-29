import EmberObject from '@ember/object';
import CasAuthenticatedRouteMixin from 'frontend/mixins/cas-authenticated-route';
import { module, test } from 'qunit';

module('Unit | Mixin | cas-authenticated-route', function() {
  // Replace this with your real tests.
  test('it works', function (assert) {
    let CasAuthenticatedRouteObject = EmberObject.extend(CasAuthenticatedRouteMixin);
    let subject = CasAuthenticatedRouteObject.create();
    assert.ok(subject);
  });
});
