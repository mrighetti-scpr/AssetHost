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
    if(!token) return this._super(...arguments);
    let tokenData;
    try {
      const payload         = token.split('.')[1],
            tokenDataString = decodeURIComponent(window.escape(atob(payload.replace (/-/g, '+').replace(/_/g, '/'))));
      tokenData = JSON.parse(tokenDataString);
    } catch (error) {
      tokenData = {};
    }
    if(token) return RSVP.resolve({
      authenticated: {
        authenticator: 'authenticator:jwt',
        exp: tokenData.exp,
        jwt: token
      }
    });
    return this._super(...arguments);
  }
});

