@Omega.module "ChannelApp", (ChannelApp, App, Backbone, Marionette, $, _) ->

  class ChannelApp.Router extends App.Routers.Base
    appRoutes:
      "topic/:id(/)" : "show"

  API =
    show: (id) ->
      new ChannelApp.Show.Controller
        id: id

  App.addInitializer ->
    new ChannelApp.Router
      controller: API
