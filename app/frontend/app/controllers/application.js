import   Controller           from '@ember/controller';
import { inject as service }  from '@ember/service';
import { computed, observer } from '@ember/object';
import { run }                from '@ember/runloop';
import { alias }              from '@ember/object/computed';

const { debounce } = run;

export default Controller.extend({
  init(){
    this._super(...arguments);
    this.set('query', '');
    this.get('connectionStatus.offline');
    this.set('simplified', false);
  },
  search: service(),
  toolbar:  service(),
  hasSimplifiedToolbar: alias('toolbar.isSimplified'),
  toolbarClass: computed('toolbar.isSimplified', function(){
    const isSimplified = this.get('toolbar.isSimplified');
    let   output       = "toolbar-component";
    if(isSimplified) output = output += " toolbar-component--simplified";
    return output;
  }),
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

