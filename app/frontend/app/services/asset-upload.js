import Service       from '@ember/service';
import { task }      from 'ember-concurrency';
import { bind } from '@ember/runloop';
import { inject as service } from '@ember/service';

function uploadURL(asset, url){
  asset.set('localFileURL', url);
  const API = this.get('API');
  return API.post('assets', { data: { url } })
           .then(resp => asset.setProperties(resp));
}

function uploadFile(asset, file){
  file.readAsDataURL().then(function (url) {
    asset.set('localFileURL', url);
  });
  const { jwt } = this.get('session.data.authenticated');
  const response = this.get('API').upload('assets', file, {
    fileKey: 'image',
    headers: {
      'Authorization': `Bearer ${jwt}`
    }
  });
  asset.setProperties(response.body);
  return response;
}

function replaceFile(asset, file){
  file.readAsDataURL().then(function (url) {
    asset.set('localFileURL', url);
  });
  const { jwt } = this.get('session.data.authenticated');
  const response = this.get('API').upload(`assets/${asset.id}`, file, {
    fileKey: 'image',
    headers: {
      'Authorization': `Bearer ${jwt}`
    },
    method: 'PUT'
  });
  asset.setProperties(response.body);
  return response;
}

function replaceURL(asset, url){
  asset.set('localFileURL', url);
  const API = this.get('API');
  return API.put(`assets/${asset.id}`, { data: { url } })
            .then(resp => asset.setProperties(resp));
}


export default Service.extend({
  store:   service(),
  session: service(),
  API:     service('api'),
  upload: task(function * (file, _asset) {
    const asset = _asset || this.store.createRecord('asset', {
      created_at: new Date(),
      isUploading: true
    });
    asset.set('isUploading', true);
    try {
      if(typeof file === 'string'){
        yield bind(this, uploadURL)(asset, file);
      } else {
        yield bind(this, uploadFile)(asset, file);
      }
      asset.set('isUploading', false);
    } catch (e) {
      asset.set('isUploading', false);
      // 🚨 Add smarter retry logic that only
      //    does its thing if there was a connection failure
      //    and if the application is online
      // later(bind(this, () => {
      //   get(this, 'upload').perform(file, asset);
      // }), 5000);
    }
  }).maxConcurrency(3).enqueue(),
  replace: task(function * (file, asset) {
    asset.set('isReplacing', true);
    try {
      if(typeof file === 'string'){
        yield bind(this, replaceURL)(asset, file);
      } else {
        yield bind(this, replaceFile)(asset, file);
      }
      asset.set('isReplacing', false);
    } catch (e) {
      asset.set('isReplacing', false);
    }
  }).maxConcurrency(1).enqueue()
});

