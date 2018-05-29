import Route from '@ember/routing/route';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';
import { inject as service } from '@ember/service';
import { hash } from 'rsvp';

export default Route.extend(AuthenticatedRouteMixin, {
  progress: service(),
  model({ id }) {
    const store = this.get('store');
    return hash({
      asset: store.findRecord('asset', id),
      outputs: store.findAll('output')
    });
  },
  beforeModel(){
    this._super(...arguments);
    this.get('progress').start(10);
  },
  afterModel(){
    this.get('progress').done(100);
  }
});

