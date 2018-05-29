import Mixin from '@ember/object/mixin';

export default Mixin.create({
  init(){
    this._super(...arguments);
    window.addEventListener("mousewheel", this.onmousewheel);
  },
  activate() {
    this._super();
    window.addEventListener("mousewheel", this.onmousewheel);
  },
  deactivate() {
    this._super();
    window.removeEventListener("mousewheel", this.onmousewheel);
  },
  willDestroy(){
    window.removeEventListener("mousewheel", this.onmousewheel);
  },
  onmousewheel(e){
    // fixes infinite scroll in chrome
    if (e.deltaY === 1) {
      e.preventDefault()
    }
  }
});
