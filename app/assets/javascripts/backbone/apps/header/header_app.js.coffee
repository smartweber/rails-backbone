@Omega.module "HeaderApp", (HeaderApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    list: ->
      headerRegion = App.request "wrapper:header:region"
      new HeaderApp.List.Controller
        region: headerRegion

  HeaderApp.on "start", ->
    API.list()
