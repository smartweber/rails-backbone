do (Backbone) ->

  Backbone.Syphon.InputReaders.register 'file', ($el, value) ->
    if $el.data('base64')
      $el.data('base64')
    else
      $el.val()
