@Omega.module "ChatApp", (ChatApp, App, Backbone, Marionette, $, _) ->

  class ChatApp.Router extends App.Routers.Base
    appRoutes:
      'messages/:id(/)' : 'show'
      'messages(/)'     : 'show'

  API =
    newMessage: (region) ->
      new ChatApp.New.Controller
        region: region

    show: (chat_id) ->
      new ChatApp.Show.Controller
        id: chat_id

  App.addInitializer ->
    new ChatApp.Router
      controller: API

  App.commands.setHandler "new:message", (region) ->
    API.newMessage region
