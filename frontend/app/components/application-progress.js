import Component from '@ember/component';
import { inject as service } from '@ember/service';
import { htmlSafe }           from '@ember/string';
import { computed }           from '@ember/object';

// import { alias } from '@ember/object/computed';

export default Component.extend({
  classNames: ['application-progress'],
  classNameBindings: [
    'progress.isActive:application-progress--active', 
    'progress.isResetting:application-progress--resetting'
  ],
  progress: service(),
  percentage: computed('progress.val', function(){
    const val = this.get('progress.val');
    return htmlSafe(`width: ${val}%;`);
  })
});

