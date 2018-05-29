import DragSortList from 'ember-drag-sort/components/drag-sort-list';
import { alias } from '@ember/object/computed';

export default DragSortList.extend({
  tagName:    'ul',
  classNames: ['asset-list'],
  items: alias('assets'),
  actions: {
    getAssets(){
      // this.sendAction('getPage');
    },
    onClick(){
      const action = this.get('onClick');
      if(typeof action === 'function') action(...arguments);
    }
  }
});

