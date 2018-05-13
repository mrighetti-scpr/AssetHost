import Route from '@ember/routing/route';
import { inject as service } from '@ember/service';
import EmberObject from '@ember/object';

export default Route.extend({
  session: service(),
  model(){
    return new EmberObject({
      username: '',
      password: ''
    });
  },
  actions: {
    login(username, password){
      const session = this.get('session');
      session.authenticate(username, password)
        .then(currentUser => {
          if(currentUser) return this.transitionTo('index');
          alert('username or password incorrect');
        });
    }
  }
});

