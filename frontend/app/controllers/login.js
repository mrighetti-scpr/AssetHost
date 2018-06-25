import Controller            from '@ember/controller';
import { inject as service } from '@ember/service';
import { computed }          from '@ember/object';

export default Controller.extend({
  session:      service(),
  paperToaster: service(),
  API:          service('api'),
  ssoURL:       computed('API', function(){
    const origin    = (typeof location === "object") ? location.origin : "http://localhost:3000",
          callback  = encodeURIComponent(`${origin}/api/authenticate/cas`);
    return this.API.fetch('authenticate/cas/url')
                   .then(json => {
                      if(!json.url) return;
                      return `${json.url}/login?service=${callback}&renew=false`;
                   });
  }),
  actions: {
    authenticate(identification, password){
      return this.get('session').authenticate('authenticator:jwt', { identification, password })
        .catch(() => {
          this.get('paperToaster').show('Username or password incorrect.', { 
            toastClass: 'application-toast application-toast--top-center' 
          });
        });
    },
    goToSSOLogin(promise){
      if(!promise || !window) return;
      promise.then(url => window.location.href = url);
    }
  }
});

