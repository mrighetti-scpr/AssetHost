import Component from '@ember/component';

export default Component.extend({
  tagName:    'ul',
  classNames: ['asset-list'],
  actions: {
    getAssets(){
      // this.sendAction('getPage');
    }
  }
});
