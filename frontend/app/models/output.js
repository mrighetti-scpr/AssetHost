import DS from 'ember-data';

const { attr } = DS;

export default DS.Model.extend({
  name:           attr('string'),
  render_options: attr({ defaultValue: () => [] }),
  prerender:      attr('boolean'),
  content_type:   attr('string'),
  created_at:     attr('date'),
  updated_at:     attr('date')
});

