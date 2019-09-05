@Omega.module "PasswordApp", (PasswordApp, App, Backbone, Marionette, $, _) ->

  class PasswordApp.Router extends App.Routers.Base
    appRoutes:
      'password/new(/)'  : 'forgot_password'
      'password/edit?reset_password_token=:reset_token' : 'update_password'

  API =
    forgot_password: ->
      new PasswordApp.New.Controller

    update_password: (reset_token) ->
      new PasswordApp.Edit.Controller
        resetToken: reset_token

  App.addInitializer ->
    $.ajaxSetup {
      statusCode: {
        401: -> 
          App.navigate Routes.new_user_session_path(), trigger: true
      }
    }
    new PasswordApp.Router
      controller: API
