import Route from '@ember/routing/route';

export default Route.extend({
  model(params){
    return this.get('store').findRecord('user', params.id);
  },
  actions: {
    willTransition(){
      const model = this.controller.get('model');
      if(model.get('isNew')) model.deleteRecord();
    }
  }
});
