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
  image_fingerprint: attr('string'),
  tags:            attr(),
  keywords:        attr('string'),
  notes:           attr('string'),
  created_at:      attr('date'),
  taken_at:        attr('date'),
  image_taken:     attr('date'),
  native:          attr(),
  image_file_size: attr(),
  url:             attr('string'),
  sizes:           attr(),
  urls:            attr(),
  orientation:     attr('string'),
  long_edge:       attr('number'),
  short_edge:      attr('number'),
  ratio:           attr('number'),
  keywordList:     computed('keywords', function(){
    return (this.get('keywords') || '')
      .split(/\s*,\s*/g)
      .filter(k => k.length);
  }),
  takenAtFormatted:     computed('taken_at', function(){
    // We need to format the date to YYYY-MM-DD to make it work with the ember-paper date picker
    const takenAt = this.get('taken_at');
    if (takenAt) {
      var d = new Date(takenAt),
          month = '' + (d.getMonth() + 1),
          day = '' + d.getDate(),
          year = d.getFullYear();

      if (month.length < 2) month = '0' + month;
      if (day.length < 2) day = '0' + day;

      return [year, month, day].join('-');
    }
  }),
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

