$(document).ready ->

  taggables = document.querySelectorAll('.taggable')

  i = 0
  while i < taggables.length
    el    = taggables[i]
    newEl = document.createElement('div')
    $(el).before newEl

    taggle = new Taggle newEl,
      tags: el.value.split(/,\s*/g).map (s) => s.trim()
      onTagAdd: (event, tag) ->
        el.innerText = taggle.getTagValues().join(', ')
      onTagRemove: (event, tag) ->
        el.innerText = taggle.getTagValues().join(', ')
    i++