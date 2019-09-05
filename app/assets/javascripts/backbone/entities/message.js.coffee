@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Message extends App.Entities.Model
    url: -> Routes.api_messages_path(@id)
    paramRoot: 'message'

    isSeen: ->
      @get('crossParticipant').get('last_seen_message_id') >= @get('id')

  class Entities.MessageCollection extends App.Entities.Collection
    model: Entities.Message
    url: ->
      Routes.api_chat_messages_path(@chat_id)

  API =
    newMessage: (attributes, chatId) ->
      message = new Entities.Message attributes
      message

    # TODO: chat seems required here, not optional
    newMessageCollection: (chat) ->
      if chat
        models = chat.get('messages')
      messages = new Entities.MessageCollection models
      messages

  App.reqres.setHandler "new:message:entity", (attributes, chatId) ->
    API.newMessage attributes, chatId

  App.reqres.setHandler "new:message:entities", (chat) ->
    API.newMessageCollection chat
