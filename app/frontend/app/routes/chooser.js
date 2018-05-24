import Route from '@ember/routing/route';
import { on } from '@ember/object/evented';
import { inject as service } from '@ember/service';

export default Route.extend({
  toolbar: service(),
  simplifyToolbar: on('activate', function(){
    this.set('toolbar.isSimplified', true);
  }),
  unsimplifyToolbar: on('deactivate', function(){
    this.set('toolbar.isSimplified', false);
  }),
  model(){
    return [{
      title: "test asset"
    }];
  }
});
