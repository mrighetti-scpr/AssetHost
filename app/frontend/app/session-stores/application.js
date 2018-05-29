import AdaptiveStore from 'ember-simple-auth/session-stores/adaptive';
import RSVP          from 'rsvp';
import queryString   from 'npm:query-string';

/**
 * If we receive a token through a query parameter, restore from that instead.
 */
export default AdaptiveStore.extend({
  restore() {
    if(typeof location !== 'object') return this._super(...arguments);
    const query = queryString.parse(location.search),
          token = query.token;
    if(token) return RSVP.resolve({
      authenticated: {
        authenticator: 'authenticator:jwt',
        exp: 1527633408,
        jwt: token
      }
    });
    return this._super(...arguments);
  }
});

