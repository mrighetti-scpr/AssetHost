import Controller    from '@ember/controller';
import { task }      from 'ember-concurrency';
import { get, 
         set,
         computed,
         observer }  from '@ember/object';
import { bind, run } from '@ember/runloop';
import { inject }    from '@ember/controller';
import MousewheelFix from '../mixins/mousewheel-fix';

const { debounce, later } = run;

export default Controller.extend(MousewheelFix, {
  init() {
    this._super(...arguments);
    this.set('pages', []);
    this.set('page', 1);
    this.send('getPage');
    this.set('isLoadingPage', false);
  },
  application: inject('application'),
  computeQuery: observer('application.query', function(){
    debounce(this, this.onQuery, 300);
  }),
  onQuery(){
    this.get('pages').clear();
    this.set('page', 1); 
    this.send('getPage', true);
  },
  upload: task(function * (file, _asset) {
    const asset = _asset || this.store.createRecord('asset', {
      created_at: new Date(),
      isUploading: true
    });
    if(!_asset) this.get('firstPage').unshiftObject(asset);
    try {
      file.readAsDataURL().then(function (url) {
        // if (get(asset, 'url') == null) set(asset, 'url', url);
        asset.set('localFileURL', url);
      });
      const response = yield file.upload('/api/assets', {
        fileKey: 'image'
      });
      asset.setProperties(response.body);
      // yield asset.save();
      asset.set('isUploading', false);
    } catch (e) {
      later(bind(this, () => {
        get(this, 'upload').perform(file, asset);
      }), 5000);
    }
  }).maxConcurrency(3).enqueue(),
  firstPage: computed(function(){
    return this.pages[0] || [];
  }),
  actions: {
    getPage(shouldClearPages){
      const page  = this.get('page');
      if(!(page > 0)) return;
      this.set('isLoadingPage', true);
      const query  = this.get('application.query'),
            q      = query.length ? query : undefined,
            params = q ? { page, q } : { page };
      this.get('store').query('asset', params)
        .then(results => {
          const assets = results.toArray();
          if(!assets.length) return this.set('page', null);
          if(shouldClearPages) this.get('pages').clear();
          this.get('pages').pushObject(results.toArray());
          this.incrementProperty('page');
        })
        .then(() => this.set('isLoadingPage', false));
    },
    uploadAsset(file){
      get(this, 'upload').perform(file);
    }
  }
});

