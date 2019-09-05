@Omega.module "SessionApp", (SessionApp, App, Backbone, Marionette, $, _) ->

  class SessionApp.Router extends App.Routers.Base
    appRoutes:
      'logout'    : 'destroy'
      'login(/)'  : 'new'

  API =
    new: ->
      new SessionApp.New.Controller

    destroy: ->
      current_user = App.request "get:current:user"
      current_user.url = Routes.destroy_user_session_path()
      current_user.destroy success: (model, response) ->
        App.execute "reset:current:user"
        App.navigate Routes.root_path(), trigger: true, replace: true


  App.addInitializer ->
    $.ajaxSetup {
      statusCode: {
        401: -> App.navigate Routes.new_user_session_path(), trigger: true
      }
    }
    new SessionApp.Router
      controller: API
