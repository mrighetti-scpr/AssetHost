import Route from '@ember/routing/route';
import bsonID from 'npm:bson-objectid';

export default Route.extend({
  model(){
    return this.get('store').findAll('user');
  },
  actions: {
    newUser(){
      const id = bsonID.generate();
      this.get('store').createRecord('user', { id });
      this.transitionTo('user', id);
    },
    editUser(user){
      this.transitionTo('user', user);
    }
  }
});

