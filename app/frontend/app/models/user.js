import DS from 'ember-data';

const { attr } = DS;

export default DS.Model.extend({
  username:  attr('string'),
  is_admin:  attr('boolean', { defaultValue: false }),
  is_active: attr('boolean', { defaultValue: true }),
  permissions: attr('array', { defaultValue: () => []})
});
