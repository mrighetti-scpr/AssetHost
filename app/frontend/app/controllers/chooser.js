import IndexController from './index';
import { inject as service }  from '@ember/service';

export default IndexController.extend({
  init(){
    this._super(...arguments);
    this.set('showEditorDialog', false);
    this.get('search').getPage();
  },
  search: service(),
  actions: {
    dragEnd({draggedItem, targetList, targetIndex}){
      const item = draggedItem.toJSON();
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
    }
  }
});
