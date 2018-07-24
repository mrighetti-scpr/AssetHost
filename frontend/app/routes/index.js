import Route from '@ember/routing/route';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';
import { inject as service } from '@ember/service';
import { alias } from '@ember/object/computed';
import { bind } from '@ember/runloop';

function onPaste({clipboardData}){
  if((typeof document === 'object') && 
      document.activeElement.tagName === 'INPUT') return; 
  const pasted = clipboardData.getData('Text');
  this.get('upload').perform(pasted);
}

export default Route.extend(AuthenticatedRouteMixin, {
  // queryParams: {
  //   q: {
  //     replace: true,
  //     refreshModel: false
  //   }
  // },
  assetUpload: service(),
  upload:      alias('assetUpload.upload'),
  search:      service(),
  activate(){
    // Check if we're in an AssetHost pop-up, and if we are,
    // automatically transition to the chooser page
    if (window.opener) {
      this.transitionTo('chooser');
    }
    this._super(...arguments);
    this.set('onPaste', bind(this, onPaste));
    if(typeof window === 'object') window.addEventListener('paste', this.get('onPaste'));
    const search = this.get('search');
    this.store.unloadAll('asset'); 
    // 🚨 Inserted this to prevent weird duplicates issue when navigating back to index.
    //    Solve that problem instead of unloading assets every time.
    search.set('page', 1);
    search.getPage();
  },
  deactivate(){
    if(typeof window === 'object') window.removeEventListener('paste', this.get('onPaste'));
  }
});

