import DS from 'ember-data';
import DataAdapterMixin from 'ember-simple-auth/mixins/data-adapter-mixin';

export default DS.RESTAdapter.extend(DataAdapterMixin, {
  namespace: 'api',
  // host: 'http://localhost:3000',
  authorize(xhr) {
    const { jwt } = this.get('session.data.authenticated');
    this.get('session.store').restore();
    xhr.setRequestHeader('Authorization', `Bearer ${jwt}`);
  }
});

