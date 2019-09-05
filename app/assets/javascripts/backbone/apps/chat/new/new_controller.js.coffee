@Omega.module "ChatApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base
    initialize: ->
      @layout     = @getLayout()
      currentUser = App.request "get:current:user"
      message     = App.request "new:message:entity"

      @listenTo @layout, 'show', =>
        @messageFormRegion message, currentUser
      @region.show @layout

    messageFormRegion: (message, currentUser) ->
      messageFormView = @getMessageFormView message, currentUser

      wrappedMessageFormView = App.request "form:wrapper", messageFormView,
        multipart: true
        onFormSuccess: (data) ->
          App.navigate Routes.chat_path(data.chat_id), trigger: true

      @layout.messageFormRegion.show wrappedMessageFormView

    getLayout: ->
      new New.Layout

    getMessageFormView: (message, currentUser) ->
      new New.MessageForm
        model: message
        currentUser: currentUser
