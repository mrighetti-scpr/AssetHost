import DS from 'ember-data';

const { attr } = DS;

export default DS.Model.extend({
  title:           attr('string'),
  caption:         attr('string'),
  owner:           attr('string'),
  size:            attr('string'),
  image_gravity:   attr('string'),
  tags:            attr(),
  keyword:         attr('string'),
  notes:           attr('string'),
  created_at:      attr('date'),
  taken_at:        attr('date'),
  native:          attr(),
  image_file_size: attr(),
  url:             attr('string'),
  sizes:           attr(),
  urls:            attr(),
  orientation:     attr('string'),
  long_edge:       attr('number'),
  short_edge:      attr('number'),
  ratio:           attr('number')
});

