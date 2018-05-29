import Component from '@ember/component';
import { observer } from '@ember/object';

export default Component.extend({
  classNames: ['image-box'],
  classNameBindings: ['isLoadingImage:image-box--loading'],
  didInsertElement(){
    const image = this.element.querySelector('.image-box__image');
    image.onload = () => {
      this.set('isLoadingImage', false);
    };
    this.showPlaceholder();
    this.waitForLoad();
  },
  refreshImage: observer('digest', function(){
    this.rerender();
  }),
  showPlaceholder: observer('height', 'width', function(){
    const height = this.get('height'),
          width  = this.get('width'),
          canvas = document.createElement('canvas'),
          placeholder = this.element.querySelector('.image-box__placeholder');
    canvas.setAttribute('width',  width);
    canvas.setAttribute('height', height);
    const blank = canvas.toDataURL('image/png');
    placeholder.src = blank;
  }),
  waitForLoad: observer('url', function(){
    this.set('isLoadingImage', true);
  })
});
