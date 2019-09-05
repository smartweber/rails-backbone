@Omega.module "UserApp", (UserApp, App, Backbone, Marionette, $, _) ->

  class UserApp.Router extends App.Routers.Base
    appRoutes:
      "signup(/)"    : "new"
      "users/:username(/)" : "show"
      "settings(/)" : "edit"

  API =
    show: (username) ->
      new UserApp.Show.Controller
        username: username

    new: ->
      new UserApp.New.Controller

    edit: ->
      new UserApp.Edit.Controller

  App.addInitializer ->
    new UserApp.Router
      controller: API
