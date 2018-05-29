import Service from '@ember/service';
import { inject as service } from '@ember/service';
import { computed } from '@ember/object';

export default Service.extend({
  session: service(),
  store:   service(),
  user:    computed('session.data.authenticated.jwt', function(){
    const token = this.get('session.data.authenticated.jwt');
    if(!token) return;
    const payload   = token.split('.')[1],
          tokenData = decodeURIComponent(window.escape(atob(payload.replace (/-/g, '+').replace(/_/g, '/'))));
    try {
      const data = JSON.parse(tokenData).data,
            user = this.store.createRecord('user', data);
      return user;
    } catch (error) {
      return null;
    }
  })
});

