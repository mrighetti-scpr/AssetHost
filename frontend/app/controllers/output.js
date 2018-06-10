/* eslint-disable ember/avoid-leaking-state-in-ember-objects */

import Controller            from '@ember/controller';
import { inject as service } from '@ember/service';

export default Controller.extend({
  paperToaster: service(),
  contentTypes: [
    "",
    "image/jpeg",
    "image/png",
    "image/gif",
    "image/webp"
  ],
  actions: {
    addRenderOption(){
      const options = this.get('model.render_options');
      if(!options) return;
      options.pushObject({
        name: "",
        properties: []
      });
    },
    destroyRenderOption(option){
      const renderOptions = this.get('model.render_options'),
            index         = renderOptions.indexOf(option);
      if(index > -1) renderOptions.removeAt(index);
    },
    addOptionProperty(option){
      option.properties.pushObject({
        name:  "",
        value: ""
      });
    },
    destroyOptionProperty(properties, property){
      const index = properties.indexOf(property);
      if(index > -1) properties.removeAt(index);
    },
    sort({draggedItem, targetList, targetIndex, sourceIndex}){
      targetList.removeAt(sourceIndex);
      targetList.insertAt(targetIndex, draggedItem);
    },
    saveOutput(){
      const model = this.get('model');
      model.save()
           .then(()  => model.reload())
           .then(()  => this.get('paperToaster').show('Output saved successfully.', { toastClass: 'application-toast' }))
           .catch(() => {
             this.get('paperToaster').show('Failed to save output.', { toastClass: 'application-toast' })
           });
    }
  }
});
