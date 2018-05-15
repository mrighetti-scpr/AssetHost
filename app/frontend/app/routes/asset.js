import Route from '@ember/routing/route';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

export default Route.extend(AuthenticatedRouteMixin, {
  model({ id }) {
    // return this.modelFor('asset').find(model => model.id === id);
    return this.get('store').findRecord('asset', id);
  }
});
