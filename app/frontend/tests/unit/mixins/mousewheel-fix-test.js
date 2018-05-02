import EmberObject from '@ember/object';
import MousewheelFixMixin from 'frontend/mixins/mousewheel-fix';
import { module, test } from 'qunit';

module('Unit | Mixin | mousewheel-fix', function() {
  // Replace this with your real tests.
  test('it works', function (assert) {
    let MousewheelFixObject = EmberObject.extend(MousewheelFixMixin);
    let subject = MousewheelFixObject.create();
    assert.ok(subject);
  });
});
