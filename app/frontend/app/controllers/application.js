import Controller from '@ember/controller';
import { inject } from '@ember/service';
import { computed } from '@ember/object';

export default Controller.extend({
  init(){
    this._super(...arguments);
    this.set('query', '');
  },
  isOffline: computed('connectionStatus.offline', function(){
    return this.get('connectionStatus.offline');
  }),
  connectionStatus: inject()
});

