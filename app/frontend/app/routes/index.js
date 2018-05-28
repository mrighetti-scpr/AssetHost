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
  queryParams: {
    q: {
      replace: true,
      refreshModel: false
    }
  },
  assetUpload: service(),
  upload:      alias('assetUpload.upload'),
  activate(){
    this._super(...arguments);
    this.set('onPaste', bind(this, onPaste));
    if(typeof window === 'object') window.addEventListener('paste', this.get('onPaste'));
    const search = this.get('controller.search');
    if(!search) return;
    search.set('page', 1);
    search.getPage();
  },
  deactivate(){
    if(typeof window === 'object') window.removeEventListener('paste', this.get('onPaste'));
  }
});

