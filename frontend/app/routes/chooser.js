import Route                 from '@ember/routing/route';
import { on }                from '@ember/object/evented';
import { inject as service } from '@ember/service';
import { Promise }           from 'rsvp';
import { A }                 from '@ember/array';
import EmberObject           from '@ember/object';

const { stringify, parse } = JSON;

export default Route.extend({
  toolbar: service(),
  simplifyToolbar: on('activate', function(){
    this.set('toolbar.isSimplified', true);
  }),
  unsimplifyToolbar: on('deactivate', function(){
    this.set('toolbar.isSimplified', false);
  }),
  model(){
    if(typeof window === 'undefined') return A();
    if(!window.opener) return A();
    return new Promise((resolve, reject) => {
      window.addEventListener('message', e => {
        if(!Array.isArray(e.data)) return resolve(A());
        this.set('source', e.source);
        this.set('origin', e.origin);
        const all = Promise.all(e.data.map(doc => {
          return this.get('store')
                     .findRecord('asset', doc.id)
                     .then(record => {
                       const asset = new EmberObject(record.serialize());
                       asset.set('caption', doc.caption);
                       return asset;
                     })
                     .catch(err => {
                       reject(err);
                     });
        }));
        resolve(all);
      });
      window.opener.postMessage('LOADED', '*');
    });
  },
  actions: {
    saveAndClose(){
      if(typeof window === 'undefined') return;
      const source = this.get('source'),
            origin = this.get('origin');
      if(!(source && origin)) return;
      const model = parse(stringify(this.controller.get('model'))).map(m => delete m.shouldPersistCaption);
      source.postMessage(model, origin);
      window.close();
    }
  }
});
