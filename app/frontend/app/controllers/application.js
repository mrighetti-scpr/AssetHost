import   Controller          from '@ember/controller';
import { inject as service } from '@ember/service';
import { observer }          from '@ember/object';
import { run }               from '@ember/runloop';

const { debounce } = run;

export default Controller.extend({
  init(){
    this._super(...arguments);
    this.set('query', '');
    this.get('connectionStatus.offline');
  },
  search: service(),
  computeQuery: observer('query', function(){
    debounce(this, this.onQuery, 300);
  }),
  onQuery(){
    this.set('search.query', this.get('query'));
  },
  showOffline: observer('connectionStatus.offline', function(){
    const isOffline = this.get('connectionStatus.offline');
    if(isOffline){
      const toast = this.get('paperToaster').show('You are offline.', {duration: false});
      this.set('toast', toast);
    } else {
      const toast = this.get('toast');
      if(toast) this.get('paperToaster').cancelToast(toast);
      this.set('toast', undefined);
    }
  }),
  connectionStatus: service(),
  paperToaster:     service(),
  session:          service(),
  progress:         service(),
  actions: {
    invalidateSession(){
      this.get('session').invalidate();
    }
  }
});

