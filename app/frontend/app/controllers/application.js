import   Controller           from '@ember/controller';
import { inject as service }  from '@ember/service';
import { computed, observer } from '@ember/object';
import { alias }              from '@ember/object/computed';


export default Controller.extend({
  init(){
    this._super(...arguments);
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

