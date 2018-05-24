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
    // dragStart(e){
    //   const node = e.currentTarget.cloneNode(true);
    //   document.body.appendChild(node);
    //   e.dataTransfer.setDragImage(node, 0, 0);
    // }
  }
});
