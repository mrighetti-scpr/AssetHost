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
    this.get('session').on('authenticationSucceeded', function(){
      // Kicks off loading results after login
      this.send('getPage');
    });
    this.get('search.query');
  },
  session:      service(),
  search:       service(),
  computeQuery: observer('search.query', function(){
    this.get('store').unloadAll();
    this.set('page', 1);
    this.set('message', undefined);
    this.send('getPage');
  }),
  assetUpload: service(),
  upload:      alias('assetUpload.upload'),
  actions: {
    getPage(){
      const page  = this.get('page');
      if(!(page > 0)) return;
      this.set('isLoadingPage', true);
      const query  = this.getWithDefault('search.query', ''),
            q      = query.length ? query : undefined,
            params = q ? { page, q } : { page };
      this.get('store').query('asset', params)
        .then(results => {
          const page       = this.get('page'),
                hasResults = results.length;
          if(!hasResults && page === 1) this.set('message', 'No assets were found.');
          if(!hasResults && page > 1)   this.set('message', 'There are no more assets to show.');
          if(!hasResults) return this.set('page', null);
          this.incrementProperty('page');
        })
        .then(() => this.set('isLoadingPage', false));
    },
    uploadAsset(file){
      get(this, 'upload').perform(file);
    }
  }
});

