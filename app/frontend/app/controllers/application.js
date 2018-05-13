import Controller            from '@ember/controller';
import { inject as service } from '@ember/service';
import { observer }          from '@ember/object';

export default Controller.extend({
  init(){
    this._super(...arguments);
    this.set('query', '');
    this.get('connectionStatus.offline');
  },
  computeQuery: observer('application.query', function(){
    // debounce(this, this.onQuery, 300);
  }),
  onQuery(){
    // this.get('pages').clear();
    this.get('store').unloadAll();
    this.set('page', 1); 
    this.send('getPage', true);
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
  actions: {
    invalidateSession(){
      this.get('session').invalidate();
    }
  }
});

