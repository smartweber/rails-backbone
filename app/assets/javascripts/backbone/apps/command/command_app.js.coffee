@Omega.module "CommandApp", (CommandApp, App, Backbone, Marionette, $, _) ->

  class CommandApp.Router extends App.Routers.Base
    appRoutes:
      "command(/)" : "show"

  API =
    show: ->
      new CommandApp.Show.Controller

  App.addInitializer ->
    new CommandApp.Router
      controller: API
