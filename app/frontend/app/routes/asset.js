import Route from '@ember/routing/route';

export default Route.extend({
  model({ id }) {
    // return this.modelFor('asset').find(model => model.id === id);
    return this.get('store').findRecord('asset', id);
  }
});
