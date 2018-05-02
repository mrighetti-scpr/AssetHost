import DS from 'ember-data';
import { computed } from '@ember/object';
import { htmlSafe } from '@ember/string';
const { attr } = DS;

export default DS.Model.extend({
  title:           attr('string'),
  caption:         attr('string'),
  owner:           attr('string'),
  size:            attr('string'),
  image_gravity:   attr('string'),
  tags:            attr(),
  keywords:        attr('string'),
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
  ratio:           attr('number'),
  tileURL:         computed('localFileURL', 'urls.lsquare', function(){
    const lsquare = this.get('urls.lsquare'),
          local   = this.localFileURL;
    return local || lsquare;
  }),
  style:           computed('tileURL', function(){
    const url = this.get('tileURL');
    if(url) return htmlSafe(`background-image: url(${url}); 
                             background-position: ${this.get('backgroundPosition')}; 
                             background-size: cover;`);
  }),
  backgroundPosition: computed('image_gravity', function(){
    const gravity = this.get('image_gravity');
    switch(gravity){
      case 'NorthWest':
        return 'top left';
      case 'West':
        return 'left';
      case 'SouthWest':
        return 'bottom left';
      case 'North':
        return 'top';
      case 'South':
        return 'bottom';
      case 'NorthEast':
        return 'top right';
      case 'East':
        return 'right';
      case 'SouthEast':
        return 'bottom right';
      default:
        return 'center'
    }
  })
});

