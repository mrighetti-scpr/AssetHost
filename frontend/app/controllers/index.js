import   Controller             from '@ember/controller';
import { get }                  from '@ember/object';
import { alias }                from '@ember/object/computed';
import { inject as service }    from '@ember/service';
import   MousewheelFix          from '../mixins/mousewheel-fix';

export default Controller.extend(MousewheelFix, {
  // queryParams: ['q'],
  init() {
    this._super(...arguments);
    this.get('session.session').restore().then(() => {
      this.set('isLoadingPage', false);
      this.get('progress').start(10);
      this.get('session').on('authenticationSucceeded', () => {
        // Kicks off loading results after login
        this.send('getPage');
      });
    });
  },
  assetUpload:  service(),
  progress:     service(),
  session:      service(),
  search:       service(),
  paperToaster: service(),
  q:            alias('search.query'),
  upload:       alias('assetUpload.upload'),
  actions: {
    getPage(){
      this.set('isLoadingPage', true);
      this.get('search').getPage()
        .then(() => this.get('progress').done(100))
        .catch(() => {})
        .then(() => this.set('isLoadingPage', false));
    },
    uploadAsset(file){
      get(this, 'upload').perform(file);
    },
    editAsset(asset){
      const shouldPersistCaption = asset.get('shouldPersistCaption');
      if(typeof shouldPersistCaption !== 'boolean') asset.set('shouldPersistCaption', true);
      this.set('selectedAsset', asset);
      this.set('showEditorDialog', true);
    },
    saveAndClose(){
      const asset = this.get('selectedAsset')
      if(!asset) return;
      this.get('store')
          .findRecord('asset', asset.id)
          .then(record => {
            return record.save()
                         .then(() => {
                          this.set('showEditorDialog', false);
                          this.get('paperToaster').show('Asset saved successfully.', { toastClass: 'application-toast' });
                         });
          })
          .catch(() => {
            this.get('paperToaster').show('Failed to save asset.', { toastClass: 'application-toast' });
          });
    },
    closeEditorDialog(){
      this.set('showEditorDialog', false);
    },
  }
});

