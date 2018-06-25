import Component            from '@ember/component';
import { inject as service} from '@ember/service';

export default Component.extend({
  classNames: ['editor-dialog'],
  store: service(),
  paperToaster: service(),
  init(){
    this._super(...arguments);
    this.set('shouldPersistCaption', false);
  },
  actions: {
    saveAndClose(){
      const asset                = this.get('asset'),
            shouldPersistCaption = asset.get('shouldPersistCaption');
      if(!shouldPersistCaption) return this.onClose();
      this.get('store')
          .findRecord('asset', asset.id)
          .then(record => {
            if(shouldPersistCaption) record.set('caption', asset.get('caption'));
            return record.save()
                         .then(() => {
                           this.onClose();
                           if(shouldPersistCaption) this.get('paperToaster').show('Caption successfully saved back to AssetHost.', { toastClass: 'application-toast' });
                           this.get('paperToaster').show('Asset saved successfully.', { toastClass: 'application-toast' });
                         });
          })
          .catch(() => {
            if(shouldPersistCaption) this.get('paperToaster').show('Failed to save caption back to AssetHost.', { toastClass: 'application-toast' });
            this.get('paperToaster').show('Failed to save asset.', { toastClass: 'application-toast' });
          });
    }
  }
});
