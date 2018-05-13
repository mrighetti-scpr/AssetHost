import Base    from 'ember-simple-auth/authenticators/base';
import { inject as service } from '@ember/service';
import fetch from 'fetch';
import Promise from 'rsvp';

export default Base.extend({
  serverTokenEndpoint: '/api/sessions',
  store: service(),
  restore() {
    return Promise();
  },
  authenticate(username, password) {
    return fetch(this.get('serverTokenEndpoint'), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json;charset=utf-8'
      },
      body: JSON.stringify({ username, password })
    }).then(resp => {
      return {fullName: "ally"};
    })
  },
  invalidate() {
    return fetch(this.get('serverTokenEndpoint'), {
      method: 'DELETE'
    });
  }
});

