import Service       from '@ember/service';
import { task }      from 'ember-concurrency';
import { get }       from '@ember/object';
import { bind, run } from '@ember/runloop';
import { inject as service } from '@ember/service';

const { later } = run;

export default Service.extend({
  store:   service(),
  session: service(),
  upload: task(function * (file, _asset) {
    const asset = _asset || this.store.createRecord('asset', {
      created_at: new Date(),
      isUploading: true
    });
    // if(!_asset) this.get('firstPage').unshiftObject(asset);
    const { jwt } = this.get('session.data.authenticated');
    try {
      file.readAsDataURL().then(function (url) {
        asset.set('localFileURL', url);
      });
      const response = yield file.upload('/api/assets', {
        fileKey: 'image',
        headers: {
          'Authorization': `Bearer ${jwt}`
        }
      });
      asset.setProperties(response.body);
      asset.set('isUploading', false);
    } catch (e) {
      later(bind(this, () => {
        get(this, 'upload').perform(file, asset);
      }), 5000);
    }
  }).maxConcurrency(3).enqueue(),
});

