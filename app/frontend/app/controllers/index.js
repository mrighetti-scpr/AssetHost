import   Controller             from '@ember/controller';
import { get }                  from '@ember/object';
import { alias }                from '@ember/object/computed';
import { inject as service }    from '@ember/service';
import   MousewheelFix          from '../mixins/mousewheel-fix';

export default Controller.extend(MousewheelFix, {
  init() {
    this._super(...arguments);
    this.send('getPage');
    this.set('isLoadingPage', false);
    this.get('progress').start(10);
    this.get('session').on('authenticationSucceeded', () => {
      // Kicks off loading results after login
      this.send('getPage');
    });
  },
  assetUpload:  service(),
  progress:     service(),
  session:      service(),
  search:       service(),
  upload:       alias('assetUpload.upload'),
  actions: {
    getPage(){
      this.get('search').getPage()
        .then(() => { 
          this.get('progress').done(100);
          this.set('isLoadingPage', false);
        });
    },
    uploadAsset(file){
      get(this, 'upload').perform(file);
    }
  }
});

