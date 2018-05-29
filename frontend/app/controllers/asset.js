import   Controller           from '@ember/controller';
import { computed, observer } from '@ember/object';
import { inject as service }  from '@ember/service';
import { htmlSafe }           from '@ember/string';
import { alias }              from '@ember/object/computed';


export default Controller.extend({
  init(){
    this._super(...arguments);
    this.set('selectedOutput', 'full');
    this.set('gravities', [
      [ "Center (default)", "Center"    ],
      [ "Top",              "North"     ],
      [ "Bottom",           "South"     ],
      [ "Left",             "West"      ],
      [ "Right",            "East"      ],
      [ "Top Left",         "NorthWest" ],
      [ "Top Right",        "NorthEast" ],
      [ "Bottom Left",      "SouthWest" ],
      [ "Bottom Right",     "SouthEast" ]
    ]);
    this.get('search.debouncedQuery');
  },
  asset:    alias('model.asset'),
  outputs:  alias('model.outputs'),
  progress: service(),
  search:   service(),
  API:      service('api'),
  onQuery:  observer('search.debouncedQuery', function(){
    this.transitionToRoute('index');
  }),
  imageURL: computed('asset.{id,fingerprint}', 'selectedOutput', function(){
    const selectedOutput = this.get('selectedOutput');
    return this.get(`asset.urls.${selectedOutput}`);
  }),
  imageTag: computed('asset.{id,fingerprint}', 'selectedOutput', function(){
    const selectedOutput = this.get('selectedOutput');
    return this.get(`asset.tags.${selectedOutput}`);
  }),
  imageSize: computed('asset.sizes', 'selectedOutput', function(){
    const selectedOutput = this.get('selectedOutput');
    return this.get(`asset.sizes.${selectedOutput}`);
  }),
  imageBoxSize: computed('imageSize', function(){
    const imageSize = this.get('imageSize');
    return htmlSafe(`min-height: 100%; width: 100%; max-height: ${imageSize.height}px; max-width: ${imageSize.width}px;`);
  }),
  imageGravity: computed('asset.image_gravity', function(){
    const gravities  = this.getWithDefault('gravities', []),
          geoGravity = this.getWithDefault('asset.image_gravity', 'Center'),
          gravity    = gravities.find(g => g[1] === geoGravity) || gravities[0];
    return gravity;
  }),
  paperToaster: service(),
  assetUpload:  service(),
  replace:      alias('assetUpload.replace'),
  actions: {
    saveAsset(){
      this.get('model')
        .save()
        .then(() => {
          this.get('paperToaster').show('Asset saved successfully.', { toastClass: 'application-toast' });
        })
        .catch(() => {
          this.get('paperToaster').show('Asset failed to save.',     { toastClass: 'application-toast' });
        });
    },
    replace(files){
      const file  = files[0],
            asset = this.get('asset');
      if(!file) return;
      this.set('isReplacing', true);
      this.get('replace')
          .perform(file, asset)
          .then(() => {
            asset.reload();
            this.set('isReplacing', false);
          });
    },
    selectOutput(outputName){
      const previous = this.get('selectedOutput');
      if(previous !== outputName) this.set('isLoadingImage', true);
      // $('#asset__image').one('load error', () => this.set('isLoadingImage', false));
      this.set('selectedOutput', outputName);
    },
    addKeyword(keyword){
      const keywords = this.getWithDefault('asset.keywords', ''),
            output   = keywords.split(/\s*,\s*/g).map(k => k.trim()).concat([keyword]).join(', ');
      this.set('asset.keywords', output);
    },
    removeKeyword(keyword){
      const keywords = this.getWithDefault('asset.keywords', '').split(/\s*,\s*/g),
            idx      = keywords.indexOf(keyword);
      keywords.splice(idx, 1);
      const output   = keywords.join(', ');
      this.set('asset.keywords', output);
    },
    setGravity(gravity){
      this.set('asset.image_gravity', gravity[1]);
    }
  }
});
