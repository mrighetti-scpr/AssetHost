import Service from '@ember/service';
import { run } from '@ember/runloop';
import Evented from '@ember/object/evented';

const { later } = run;

export default Service.extend(Evented, {
  val: 0,
  init(){
    this._super(...arguments);
    this.reset();
  },
  start(value=0){
    this.set('val', value);
    later(this, () => {
      // For some reason, this prevents the bar from
      // animating backwards.
      this.set('isActive', true);
      this.set('isDone', false);
      this.trigger('start');
    }, 0);
  },
  done(value){
    later(this, () => {
      if(value > -1) this.set('val', value);
      this.set('isActive', false);
      this.set('isDone', true);
      this.trigger('done');
    }, 1000);
  },
  increment(value){
    later(this, () => {
      this.set('val', value);
      this.trigger('increment');
    }, 0);
  },
  reset(){
    this.set('isActive', false);
    this.set('val', 0);
    this.set('isDone', false);
    this.set('isResetting', false);
    this.trigger('reset');
    // this.set('isResetting', true);
    // later(this, () => {
    //   this.set('isActive', false);
    //   this.set('val', 0);
    //   this.set('isDone', false);
    //   this.set('isResetting', false);
    //   this.trigger('reset');
    // }, 0);
  }
});

