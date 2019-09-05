@Omega.module "VisibilityObserverApp", (VisibilityObserverApp, App, Backbone, Marionette, $, _) ->
  API =
    # @note uses PageVisibility API http://www.w3.org/TR/page-visibility/
    start: ->
      hidden = 'hidden'
      # Standards:

      onchange = (evt) ->
        v = 'visible'
        h = 'hidden'
        evtMap =
          focus: v
          focusin: v
          pageshow: v
          blur: h
          focusout: h
          pagehide: h
        evt = evt or window.event
        visibility = if evt.type of evtMap
          evtMap[evt.type]
        else
         if @[hidden] then 'hidden' else 'visible'
        App.vent.trigger "visibility:change", visibility
        return

      if hidden of document
        document.addEventListener 'visibilitychange', onchange
      else if (hidden = 'mozHidden') of document
        document.addEventListener 'mozvisibilitychange', onchange
      else if (hidden = 'webkitHidden') of document
        document.addEventListener 'webkitvisibilitychange', onchange
      else if (hidden = 'msHidden') of document
        document.addEventListener 'msvisibilitychange', onchange
      else if 'onfocusin' of document
        document.onfocusin = document.onfocusout = onchange
      else
        window.onpageshow = window.onpagehide = window.onfocus = window.onblur = onchange
      # set the initial state (but only if browser supports the Page Visibility API)
      if document[hidden] != undefined
        onchange type: if document[hidden] then 'blur' else 'focus'
      return

  VisibilityObserverApp.on "start", ->
    API.start()
