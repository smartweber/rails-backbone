@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.FlashMessage extends App.Entities.Model

  class Entities.FlashMessageCollection extends App.Entities.Collection
    model: Entities.FlashMessage

  App.FlashMessages = new Entities.FlashMessageCollection

  API =
    getFlashMessageList: ->
      App.FlashMessages

    addFlashMessage: (attributes) ->
      App.FlashMessages.add attributes
      App.FlashMessages

    resetFlashMessageList: () ->
      App.FlashMessages.reset()
      App.FlashMessages

    removeFlashMessage: (attributes) ->
      App.FlashMessages.remove attributes
      App.FlashMessages

  App.reqres.setHandler "get:instant-message:list", ->
    API.getFlashMessageList()

  App.reqres.setHandler "add:instant-message:entity", (attributes) ->
    API.resetFlashMessageList()
    API.addFlashMessage attributes

  App.reqres.setHandler "remove:instant-message:entity", (attributes) ->
    API.removeFlashMessage attributes

  App.reqres.setHandler "reset:instant-message:list", (attributes) ->
    API.resetFlashMessageList()
