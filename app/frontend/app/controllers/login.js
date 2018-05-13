import Controller from '@ember/controller';
import { inject as service } from '@ember/service';

export default Controller.extend({
  session: service('session'),
  actions: {
    authenticate(username, password){
      this.get('session').authenticate('authenticator:assethost', username, password)
        .catch(reason => {
          this.set('errorMessage', reason.error || reason);
        });
    }
  }
});
