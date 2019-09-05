@Omega.module "FooterApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: ->
      @footerView = @getFooterView()

    getFooterView: ->
      new List.Footer

  App.reqres.setHandler "footer:controller", ->
    new List.Controller
