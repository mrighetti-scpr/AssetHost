(function(){

  function documentReady(fn) {
    if (document.attachEvent ? document.readyState === "complete" : document.readyState !== "loading"){
      fn();
    } else {
      document.addEventListener('DOMContentLoaded', fn);
    }
  }

  documentReady(() => {
    const query = document.querySelectorAll('[data-assethost]'),
          els   = Array.from(query);

    els.forEach(element => {
      const type = element.getAttribute('data-ah-type');
      // if(type === 'youtube')
    });
  });
  
})();