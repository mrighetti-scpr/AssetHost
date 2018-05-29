import Component            from '@ember/component';
import { inject as service} from '@ember/service';
import { computed }         from '@ember/object';

export default Component.extend({
  classNames: ['editor-dialog'],
  store: service(),
  paperToaster: service(),
  init(){
    this._super(...arguments);
    this.set('shouldPersistCaption', false);
  },
  didReceiveAttrs(){
    const asset = this.get('asset');
    if(!asset) return;
    this.set('title',   asset.title);
    this.set('credit',  asset.credit);
    this.set('notes',   asset.notes);
    this.set('caption', asset.caption);
  },
  metadataHasChanged: computed('title', 'credit', 'notes', function(){
    return (this.get('title')  !== this.get('asset.title'))  || 
           (this.get('credit') !== this.get('asset.credit')) ||
           (this.get('notes')  !== this.get('asset.notes'));
  }),
  actions: {
    saveAndClose(){
      const shouldPersistCaption = this.get('shouldPersistCaption'),
            metadataHasChanged   = this.get('metadataHasChanged');
      if(!metadataHasChanged && !shouldPersistCaption) return this.onClose();
      const asset  = this.get('asset');
      asset.set('caption', this.get('caption'));
      asset.set('title',  this.get('title'));
      asset.set('credit', this.get('credit'));
      asset.set('notes',  this.get('notes'));
      this.get('store')
          .findRecord('asset', asset.id)
          .then(record => {
            if(metadataHasChanged){
              record.set('title',  this.get('title'));
              record.set('credit', this.get('credit'));
              record.set('notes',  this.get('notes'));
            }
            if(shouldPersistCaption){
              record.set('caption', this.get('caption'));
            }
            return record.save()
                         .then(() => {
                           this.onClose();
                           this.get('paperToaster').show('Asset saved successfully');
                         });
          })
          .catch(() => {
            this.get('paperToaster').show('Failed to save asset.');
          });
    }
  }
});
