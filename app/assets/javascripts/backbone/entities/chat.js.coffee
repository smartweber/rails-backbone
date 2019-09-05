@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Chat extends App.Entities.Model
    initialize: ->
      participants = App.request "new:participant:entities", @get('participants')
      @set participants: participants
      messages     = App.request "new:message:entities", @
      @listenTo messages, 'add', (model) =>
        @injectParticipantsIntoMessage(model)
      @set messages: messages
      @injectParticipantsIntoMessages()

    urlRoot: ->
      Routes.api_chats_path()

    fetchRecentMessages: ->
      unless @isNew()
        messages = @get('messages')
        messages.chat_id = @id
        messages.fetch()
      else
        collection = App.request "new:message:entities"
        @set messages: collection

    addMessage: (message) ->
      @get('messages').push message
      @trigger 'change:messages'

    unseenMessagesCountFor: (userId) ->
      participant = @getParticipantByUserId userId
      notSeenMessages = _.filter @get('messages').models, (model) ->
        model.get('id') > participant.get('last_seen_message_id') and model.get('participant_id') != participant.get('id')
      notSeenMessages.length

    lastMessage: ->
      _.last(@get('messages').models)

    lastMessageByRecipient: ->
      _.last =>
        _.filter @get('messages').models, (model) =>
          # TODO: change this
          model.get('participant_id') != @getParticipantByUserId().get('id')

    updateLastSeenMessageId: (userId) ->
      participant = @getParticipantByUserId userId
      participant.save {last_seen_message_id: @lastMessage().id},
        patch: true
        success: (model, response, options) =>
          @markPreviousMessagesReadFor(participant)
          @trigger 'previous:messages:marked:read'
        # TODO: error handler

    markPreviousMessagesReadFor: (participant, topReadMessage) ->
      lastMessage = topReadMessage || @lastMessage()
      participant.set('last_seen_message_id', lastMessage.id)

    injectParticipantsIntoMessage: (message) ->
      participantId    = message.get('participant_id')
      participant      = @getParticipantById participantId
      crossParticipant = @getCrossParticipantById participantId
      message.set participant: participant, crossParticipant: crossParticipant

    injectParticipantsIntoMessages: ->
      messages = @get('messages')
      _.each messages.models, (model, index, list) =>
        if model.get('participant') == undefined
          @injectParticipantsIntoMessage(model)
      messages.trigger('parsed')

    getInterlocutor: ->
      currentUserId = App.request("get:current:user").id
      notCurrentUserParticipants = @get('participants').filter (model) ->
        model.get('user_id') != currentUserId
      new App.Entities.Participant _.first(notCurrentUserParticipants)

    getParticipantById: (participantId) ->
      @get('participants').findWhere({ id: participantId })

    getCrossParticipantById: (participantId) ->
      crossParticipants = _.reject @get('participants').models, (participant) ->
        participant.get('id') == participantId
      crossParticipants[0]

    getParticipantByUserId: (userId) ->
      unless userId?
        userId = App.request("get:current:user").id
      @get('participants').findWhere({ user_id: userId })

  class Entities.ChatCollection extends App.Entities.Collection
    model: Entities.Chat
    url: ->
      Routes.api_chats_path()

    addMessage: (message) ->
      chatId = { id: message.get('chat_id') }
      chat   = @findWhere chatId
      chat  ?= App.request "new:chat:entity", chatId
      App.execute 'when:fetched', chat, =>
        chat.addMessage message
        @add chat

  API =
    show: (chat_id) ->
      chat = new Entities.Chat id: chat_id
      chat.fetch()
      chat

    getChats: ->
      chats = new Entities.ChatCollection
      chats.fetch()
      chats

    newChat: (attributes) ->
      chat = new Entities.Chat attributes
      chat

  App.reqres.setHandler "get:chat:entity", (chatId) ->
    API.show chatId

  App.reqres.setHandler "get:chat:entities", ->
    API.getChats()

  App.reqres.setHandler "new:chat:entity", (attributes) ->
    API.newChat attributes
