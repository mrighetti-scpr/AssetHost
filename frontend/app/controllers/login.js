import Controller            from '@ember/controller';
import { inject as service } from '@ember/service';
import { computed }          from '@ember/object';

export default Controller.extend({
  session:      service(),
  paperToaster: service(),
  ssoURL:       computed(function(){
    // const routing = this.get('routing'),
    //       params  = Object.values(transition.params).filter(param => Object.values(param).length),
    //       url     = routing.generateURL(transition.targetName, params, transition.queryParams);
    const callback  = encodeURIComponent("http://localhost:3000/api/authenticate");
    return `https://login.scprdev.org/login?service=${callback}&renew=false`;
  }),
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

