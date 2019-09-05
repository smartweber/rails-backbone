@Omega.module "FooterApp", (FooterApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  # TODO: Use Marionette.Object instead of Controller as per documentation advice for all usecases without router
  API =
    list: ->
      new FooterApp.List.Controller
        region: App.rightColumnRegion

  FooterApp.on "start", ->
    API.list()
