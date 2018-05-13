import Route from '@ember/routing/route';
import ApplicationRouteMixin from 'ember-simple-auth/mixins/application-route-mixin';

export default Route.extend(ApplicationRouteMixin, {
  // model(){
  //   return this.get('store').queryRecord('session', {});
  // },
  // actions: {
  //   error(error) {
  //     debugger
  //     if (error && error.status === 401) return this.transitionTo('login');
  //     // Return true to bubble this event to any parent route.
  //     return true;
  //   }
  // }
});

