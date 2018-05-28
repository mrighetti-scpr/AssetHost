import Route from '@ember/routing/route';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';
import { inject as service } from '@ember/service';

export default Route.extend(AuthenticatedRouteMixin, {
  progress: service(),
  model({ id }) {
    return this.get('store').findRecord('asset', id);
  },
  beforeModel(){
    this._super(...arguments);
    this.get('progress').start(10);
  },
  afterModel(){
    this.get('progress').done(100);
  }
});

