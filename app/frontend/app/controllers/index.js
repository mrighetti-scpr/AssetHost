import   Controller             from '@ember/controller';
import { get, 
         observer }             from '@ember/object';
import { alias }                from '@ember/object/computed';
import { inject as service }    from '@ember/service';
import   MousewheelFix          from '../mixins/mousewheel-fix';

export default Controller.extend(MousewheelFix, {
  init() {
    this._super(...arguments);
    this.set('page', 1);
    this.send('getPage');
    this.set('isLoadingPage', false);
    this.set('results', this.get('store').peekAll('asset'));
    this.get('progress').start(10);
    this.get('session').on('authenticationSucceeded', () => {
      // Kicks off loading results after login
      this.send('getPage');
    });
    this.get('search.query');
  },
  assetUpload:  service(),
  progress:     service(),
  session:      service(),
  search:       service(),
  upload:       alias('assetUpload.upload'),
  computeQuery: observer('search.query', function(){
    this.get('store').unloadAll();
    this.set('page', 1);
    this.set('message', undefined);
    this.send('getPage');
  }),
  actions: {
    didTransition(){
      debugger
    },
    getPage(){
      const page  = this.get('page');
      if(!(page > 0)) return;
      this.set('isLoadingPage', true);
      const query  = this.getWithDefault('search.query', ''),
            q      = query.length ? query : undefined,
            params = q ? { page, q } : { page };
      this.get('progress').start(10);
      this.get('store').query('asset', params)
        .then(results => {
          const page       = this.get('page'),
                hasResults = results.length;
          if(!hasResults && page === 1) this.set('message', 'No assets were found.');
          if(!hasResults && page > 1)   this.set('message', 'There are no more assets to show.');
          if(!hasResults) return this.set('page', null);
          this.incrementProperty('page');
        })
        .catch(err => console.error(err))
        .then(() => { 
          this.get('progress').done(100);
          this.set('isLoadingPage', false);
        });
    },
    uploadAsset(file){
      get(this, 'upload').perform(file);
    }
  }
});

