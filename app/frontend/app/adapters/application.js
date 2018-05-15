import DS from 'ember-data';
import { inject as service } from '@ember/service';
import DataAdapterMixin from 'ember-simple-auth/mixins/data-adapter-mixin';

export default DS.RESTAdapter.extend(DataAdapterMixin, {
  namespace: 'api',
  session: service(),
  authorize(xhr) {
    const { jwt } = this.get('session.data.authenticated');
    xhr.setRequestHeader('Authorization', `Bearer ${jwt}`);
  }
});

