import Service from '@ember/service';
import { inject as service } from '@ember/service';
import { bind } from '@ember/runloop';

/**
 * Used to make arbitrary API requests that use the Application Adapter,
 * hence automatically inheriting integration with authentication, etc.
 */
export default Service.extend({
  store:   service(),
  session: service(),
  fetch(path, options){
    return bind(this, this.request)('GET', path, options);
  },
  post(path, options){
    return bind(this, this.request)('POST', path, options);
  },
  put(path, options){
    return bind(this, this.request)('PUT', path, options);
  },
  delete(path, options){
    return bind(this, this.request)('DELETE', path, options);
  },
  upload(path, file, options={}){
    const adapter           = this.get('store').adapterFor('application'),
        { host, namespace } = adapter,
          url               = [host, namespace, path].filter(i => i).join('/');
    return file.upload(url, options); 
  },
  request(method, path, options={}){
    const adapter           = this.get('store').adapterFor('application'),
        { host, namespace } = adapter,
          url               = [host, namespace, path].filter(i => i).join('/');
    return adapter.ajax(url, method, options);
  }
});

