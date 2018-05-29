import Service from '@ember/service';
import { computed } from '@ember/object';

export default Service.extend({
  online: false,
  offline: computed.not('online'),
  init(){
    this._super(...arguments);
    this.set('online', navigator.onLine);
    const updateStatus = () => {
      this.set('online', navigator.onLine);
      if (this.get('online')) {
        // console.log('Connection status: User has gone online');
      } else {
        // console.log('Connection status: User has gone offline');
      }
    };
    window.addEventListener('online', updateStatus);
    window.addEventListener('offline', updateStatus);
  }
});
