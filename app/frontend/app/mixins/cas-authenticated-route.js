import Mixin from '@ember/object/mixin';
import { inject as service } from '@ember/service';

export default Mixin.create({

    session: service('session'),
    routing: service('-routing'),

    // beforeModel(transition) {
    //     if (this.get('session.isAuthenticated')) return this._super(...arguments);
    //     return this.get('session').authenticate('authenticator:jwt').then(() => {
    //         return this._super(...arguments);
    //     }).catch(() => {
    //         // Reference: http://stackoverflow.com/a/39054607/414097
    //         const routing = this.get('routing'),
    //               params  = Object.values(transition.params).filter(param => Object.values(param).length),
    //               url     = routing.generateURL(transition.targetName, params, transition.queryParams);
    //         const callback  = encodeURIComponent("http://localhost:3000/api/authenticate");
    //         window.location = `https://login.scprdev.org/login?service=${callback}&renew=false`
    //     });
    // }
});

