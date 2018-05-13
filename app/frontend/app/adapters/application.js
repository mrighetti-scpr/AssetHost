import DS from 'ember-data';
import { inject as service } from '@ember/service';
import DataAdapterMixin from 'ember-simple-auth/mixins/data-adapter-mixin';

export default DS.RESTAdapter.extend({
  namespace: "api",
  session: service(),
  // authenticator: 'authenticator:assethost',
  authorize(){
    
  },
  isInvalid(status){
    if(status === 401) this.get('session').invalidate();
    return this._super(...arguments);
  }
});

