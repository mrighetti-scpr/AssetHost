import Route from '@ember/routing/route';
import bsonID from 'npm:bson-objectid';

export default Route.extend({
  model(){
    return this.get('store').findAll('output');
  },
  actions: {
    newOutput(){
      const id = bsonID.generate();
      this.get('store').createRecord('output', { id });
      this.transitionTo('output', id);
    },
    editOutput(output){
      this.transitionTo('output', output);
    }
  }
});

