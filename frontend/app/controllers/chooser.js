import IndexController from './index';
import { inject as service }  from '@ember/service';
import EmberObject from '@ember/object';

export default IndexController.extend({
  init(){
    this._super(...arguments);
    this.set('showEditorDialog', false);
    this.get('search').getPage();
  },
  search: service(),
  actions: {
    getPage(){
      this.get('search').getPage();
    },
    dragEnd({draggedItem, targetList, targetIndex}){
      const item = new EmberObject(draggedItem.toJSON());
      item.id = draggedItem.get('id');
      targetList.insertAt(targetIndex, item);
    },
    sort({draggedItem, targetList, targetIndex, sourceIndex}){
      targetList.removeAt(sourceIndex);
      targetList.insertAt(targetIndex, draggedItem);
    },
    editAsset(asset){
      this.set('selectedAsset', asset);
      this.set('showEditorDialog', true);
    },
    closeEditorDialog(){
      this.set('showEditorDialog', false);
    },
    showAsset(asset){
      this.set('selectedAsset', asset);
      this.set('showAssetDialog', true);
    },
    closeAssetDialog(){
      this.set('showAssetDialog', false);
    },
    removeAsset(asset){
      const model = this.get('model'),
            index = model.indexOf(asset);
      if(index > -1) model.removeAt(index);
    }
  }
});
