import Controller from '@ember/controller';
import { inject as service } from '@ember/service';

export default Controller.extend({
  session: service(),
  paperToaster: service(),
  actions: {
    authenticate(identification, password){
      return this.get('session').authenticate('authenticator:jwt', { identification, password })
        .catch(() => {
          this.get('paperToaster').show('Username or password incorrect.', { 
            toastClass: 'application-toast application-toast--top-center' 
          });
        });
    }
  }
});

