import Controller    from '@ember/controller';
import { get, 
         observer }  from '@ember/object';
import { inject as controller } from '@ember/controller';
import { alias }     from '@ember/object/computed';
import { run }       from '@ember/runloop';
import { inject }    from '@ember/service';
import MousewheelFix from '../mixins/mousewheel-fix';

const { debounce } = run;

export default Controller.extend(MousewheelFix, {
  init() {
    this._super(...arguments);
    // this.set('pages', []);
    this.set('page', 1);
    this.send('getPage');
    this.set('isLoadingPage', false);
    this.set('results', this.get('store').peekAll('asset'));
  },
  application: controller(),
  computeQuery: observer('application.query', function(){
    debounce(this, this.onQuery, 300);
  }),
  onQuery(){
    this.get('store').unloadAll();
    this.set('page', 1); 
    this.send('getPage', true);
  },
  assetUpload: inject(),
  upload:      alias('assetUpload.upload'),
  actions: {
    getPage(){
      const page  = this.get('page');
      if(!(page > 0)) return;
      this.set('isLoadingPage', true);
      const query  = this.getWithDefault('application.query', ''),
            q      = query.length ? query : undefined,
            params = q ? { page, q } : { page };
      this.get('store').query('asset', params)
        .then(results => {
          if(!results.length) return this.set('page', null);
          // if(shouldClearPages) this.get('store').unloadAll();
          this.incrementProperty('page');
        })
        .then(() => this.set('isLoadingPage', false));
    },
    uploadAsset(file){
      get(this, 'upload').perform(file);
    }
  }
});

