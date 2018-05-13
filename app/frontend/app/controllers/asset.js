import Controller from '@ember/controller';
import { computed } from '@ember/object';
import { inject as service } from '@ember/service';
import $ from 'jquery';

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
  },
  imageURL: computed('model.id', 'selectedOutput', function(){
    const selectedOutput = this.get('selectedOutput');
    return this.get(`model.urls.${selectedOutput}`);
  }),
  imageTag: computed('model.id', 'selectedOutput', function(){
    const selectedOutput = this.get('selectedOutput');
    return this.get(`model.tags.${selectedOutput}`);
  }),
  imageGravity: computed('model.image_gravity', function(){
    const gravities  = this.getWithDefault('gravities', []),
          geoGravity = this.getWithDefault('model.image_gravity', 'Center'),
          gravity    = gravities.find(g => g[1] === geoGravity) || gravities[0];
    return gravity;
  }),
  paperToaster: service(),
  actions: {
    saveAsset(){
      this.get('model')
        .save()
        .then(() => {
          this.get('paperToaster').show('Asset saved successfully.', { toastClass: 'application-toast' });
        })
        .catch(() => {
          this.get('paperToaster').show('Asset failed to save.', { toastClass: 'application-toast' });
        });
    },
    selectOutput(outputName){
      const previous = this.get('selectedOutput');
      if(previous !== outputName) this.set('isLoadingImage', true);
      $('#asset__image').one('load error', () => this.set('isLoadingImage', false));
      this.set('selectedOutput', outputName);
    },
    addKeyword(keyword){
      const keywords = this.getWithDefault('model.keywords', ''),
            output   = keywords.split(/\s*,\s*/g).map(k => k.trim()).concat([keyword]).join(', ');
      this.set('model.keywords', output);
    },
    removeKeyword(keyword){
      const keywords = this.getWithDefault('model.keywords', '').split(/\s*,\s*/g),
            idx      = keywords.indexOf(keyword);
      keywords.splice(idx, 1);
      const output   = keywords.join(', ');
      this.set('model.keywords', output);
    },
    setGravity(gravity){
      this.set('model.image_gravity', gravity[1]);
    }
  }
});
