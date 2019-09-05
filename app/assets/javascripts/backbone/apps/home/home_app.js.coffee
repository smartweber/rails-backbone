@Omega.module "HomeApp", (HomeApp, App, Backbone, Marionette, $, _) ->

  class HomeApp.Router extends App.Routers.Base
    appRoutes:
      "" : "list"

  API =
    list: ->
      new HomeApp.List.Controller

  App.addInitializer ->
    new HomeApp.Router
      controller: API
