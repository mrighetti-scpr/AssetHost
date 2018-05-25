import Service, { inject as service } from '@ember/service';
import { observer }                   from '@ember/object';
import { run }                        from '@ember/runloop';

const { debounce } = run;

export default Service.extend({
  init(){
    this._super(...arguments);
    this.set('page', 1);
    this.set('results', this.get('store').peekAll('asset'));
  },
  query: '',
  debouncedQuery: '',
  store: service(),
  computeQuery: observer('query', function(){
    debounce(this, this.onQuery, 300);
  }),
  onQuery(){
    this.set('debouncedQuery', this.get('query'));
    this.get('store').unloadAll();
    this.set('page', 1);
    this.set('message', undefined);
    this.getPage();
  },
  getPage(){
    const page  = this.get('page');
    if(!(page > 0)) return;
    this.set('isLoadingPage', true);
    const query  = this.getWithDefault('query', ''),
          q      = query.length ? query : undefined,
          params = q ? { page, q } : { page };
    return this.get('store').query('asset', params)
      .then(results => {
        const page       = this.get('page'),
              hasResults = results.length;
        if(!hasResults && page === 1) this.set('message', 'No assets were found.');
        if(!hasResults && page > 1)   this.set('message', 'There are no more assets to show.');
        if(!hasResults) return this.set('page', null);
        this.incrementProperty('page');
      });
  }
});

