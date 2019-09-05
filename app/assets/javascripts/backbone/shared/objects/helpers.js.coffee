@Omega.module 'Helpers', (Helpers, App, Backbone, Marionette, $, _) ->

  API =
    getCurrentPageCashtag: ->
      matchResults = Backbone.history.fragment.match(/c\/([a-zA-Z.]+)/)
      if matchResults then matchResults[1] else null

  App.reqres.setHandler "current:page:cashtag", ->
    API.getCurrentPageCashtag()
