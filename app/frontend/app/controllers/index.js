import Controller   from '@ember/controller';
import { task }     from 'ember-concurrency';
import { get, 
         set, 
         computed } from '@ember/object';

export default Controller.extend({
  init() {
    this._super(...arguments);
    this.pages = [];
    this.getPage();
  },
  getPage(){
    this.get('store')
      .findAll('asset')
      .then(results => this.get('pages').pushObject(results));
  },
  upload: task(function * (file) {
    const asset = this.store.createRecord('asset', {
      created_at: new Date()
    });
    try {
      file.readAsDataURL().then(function (url) {
        if (get(asset, 'url') == null) set(asset, 'url', url);
      });
      const response = yield file.upload('/api/assets', {
        fileKey: 'image'
      });
      asset.setProperties(response.body);
      // yield asset.save();
    } catch (e) {
      // asset.rollback();
    }
  }).maxConcurrency(3).enqueue(),
  actions: {
    uploadAsset(file){
      get(this, 'upload').perform(file);
    }
  }
});
