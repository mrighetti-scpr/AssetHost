import Controller    from '@ember/controller';
import { get, 
         computed,
         observer }  from '@ember/object';
import { alias }     from '@ember/object/computed';
import { run }       from '@ember/runloop';
import { inject }    from '@ember/service';
import MousewheelFix from '../mixins/mousewheel-fix';

const { debounce } = run;

export default Controller.extend(MousewheelFix, {
  init() {
    this._super(...arguments);
    this.set('pages', []);
    this.set('page', 1);
    this.send('getPage');
    this.set('isLoadingPage', false);
  },
  computeQuery: observer('application.query', function(){
    debounce(this, this.onQuery, 300);
  }),
  onQuery(){
    this.get('pages').clear();
    this.set('page', 1); 
    this.send('getPage', true);
  },
  firstPage: computed(function(){
    return this.pages[0] || [];
  }),
  assetUpload: inject(),
  upload:      alias('assetUpload.upload'),
  actions: {
    getPage(shouldClearPages){
      const page  = this.get('page');
      if((page < 1)) return;
      this.set('isLoadingPage', true);
      const query  = this.getWithDefault('application.query', ''),
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

