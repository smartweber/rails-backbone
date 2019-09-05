@Omega.module "FavoritesApp", (FavoritesApp, App, Backbone, Marionette, $, _) ->

  class FavoritesApp.Router extends App.Routers.Base
    appRoutes:
      "collection(/)" : "index"

  API =
    index: ->
      new FavoritesApp.Index.Controller

  App.addInitializer ->
    new FavoritesApp.Router
      controller: API
