(function(){

  const { from }   = Array,
          swappers = {
            youtube: function(element){
              const videoId = element.getAttribute('data-ah-videoid');
              element.outerHTML = `<iframe type='text/html' src='https://www.youtube.com/embed/${videoId}' frameborder='0' allowfullscreen='true' />`;
            },
            vimeo: function(element){
              const videoId = element.getAttribute('data-ah-videoid');
              element.outerHTML = `<iframe src="http://player.vimeo.com/video/${videoId}?portrait=0&amp;byline=0" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>`;              
            }
          };

  function documentReady(fn) {
    if (document.attachEvent ? document.readyState === 'complete' : document.readyState !== 'loading'){
      fn();
    } else {
      document.addEventListener('DOMContentLoaded', fn);
    }
  }

  documentReady(() => {
    const query = document.querySelectorAll('[data-assethost]'),
          els   = from(query);

    els.forEach(element => {
      const type = element.getAttribute('data-ah-type');
      if(!type) return;
      (swappers[type] || function(){})(element);
    });
  });
  
})();

