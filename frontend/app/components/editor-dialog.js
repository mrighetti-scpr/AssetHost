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
      const asset = this.get('asset');
      this.get('store')
          .findRecord('asset', asset.id)
          .then(record => {
            record.setProperties(asset);
            return record.save()
              .then(() =>{
                this.onClose();
                this.get('paperToaster').show('Asset saved successfully.', { toastClass: 'application-toast' });
              })
              .catch(() => {
                this.get('paperToaster').show('Failed to save asset.', { toastClass: 'application-toast' });
              });
          })
          .catch(() => {
            this.get('paperToaster').show('Failed to save asset.', { toastClass: 'application-toast' });
          });
    }
  }
});
