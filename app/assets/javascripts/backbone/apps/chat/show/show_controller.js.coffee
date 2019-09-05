@Omega.module "ChatApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options) ->
      @layout     = @getLayoutView()
      currentUser = App.request "get:current:user"
      chats       = App.request "get:chat:entities"

      App.execute "when:fetched", chats, =>
        @setCurrentChat chats, options
        App.execute "websocket:chats:subscribe", chats.pluck('id')

        App.execute "when:fetched", [@currentChat.get('messages'), currentUser], =>
          @setPageTitle()
          participant = @currentChat.getInterlocutor()
          App.vent.on "new:message:received", (messageDetails) =>
            if messageDetails.message_type == 'read_status_update'
              participant = @currentChat.getParticipantByUserId(messageDetails.participant.user_id)
              @currentChat.markPreviousMessagesReadFor(participant)
            else
              message = App.request "new:message:entity", messageDetails.message
              chats.addMessage(message)
              @refreshPageTitle()

          App.vent.on "new:chat:received", (chatAttributes) ->
            chat = App.request "new:chat:entity", chatAttributes
            chats.push(chat)

          @listenTo @layout, "show", =>
            @chatsRegion chats
            @messagingRegion currentUser, participant, @currentChat
            @rightColumnRegion()

          @show @layout

    pageTitle: ->
      currentUser = App.request "get:current:user"
      unreadMessagesCount = @currentChat.unseenMessagesCountFor(currentUser.get('id'))
      if unreadMessagesCount > 0
        "#{unreadMessagesCount} Messages |Stockharp"
      else
        "Stockharp Message Center"

    setCurrentChat: (chats, options) ->
      if options.id?
        @currentChat = chats.findWhere({ id: parseInt(options.id) })
        App.execute("add:instant-messages", "Chat not found. You've been redirected.") unless @currentChat
      @currentChat ?= _.first(chats.models)
      @currentChat ?= App.request "new:chat:entity"
      unless @currentChat.isNew()
        @currentChat.set({current: true})
        App.navigate Routes.chat_path(@currentChat.id), replace: true
        @listenTo @currentChat, 'previous:messages:marked:read', =>
          @refreshPageTitle()
      @currentChat.fetchRecentMessages()

    messagingRegion: (currentUser, participant, currentChat) ->
      @messagingLayout = @getMessagingLayoutView currentChat
      @listenTo @messagingLayout, "show", =>
        unless currentChat.isNew()
          @chatInfoRegion participant
          @messagesRegion @currentChat.get('messages'), currentUser
          @newMessageRegion @currentChat, currentUser

      @layout.messagingRegion.show @messagingLayout

    chatsRegion: (chats) ->
      chatsView = @getChatsView chats

      @listenTo chatsView, 'new:message:button:clicked', ->
        App.execute 'new:message', @layout.messagingRegion

      @listenTo chatsView, 'childview:chat:clicked', (childview) =>
        App.navigate Routes.chat_path(childview.model.id), trigger: true

      @layout.chatsRegion.show chatsView

    chatInfoRegion: (participant) ->
      chatInfoView = @getChatInfoView participant
      @messagingLayout.chatInfoRegion.show chatInfoView

    messagesRegion: (messages, currentUser) ->
      messagesView = @getMessagesView messages, currentUser

      @messagingLayout.messagesRegion.show messagesView

    newMessageRegion: (chat, currentUser) ->
      newMessageView = @getNewMessageView chat, currentUser

      @listenTo newMessageView, 'create:message:button:clicked', =>
        unless @currentChat.isNew()
          obj          = Backbone.Syphon.serialize newMessageView
          obj.chat_id  = @currentChat.id
          App.vent.trigger "create:message:button:clicked", obj, chat.get('id')
          newMessageView.render()

      unless chat.isNew()
        @listenTo newMessageView, 'mark:previous:messages:seen', =>
          @currentChat.updateLastSeenMessageId(currentUser.get('id'))
        wrappedMessageView = App.request "form:wrapper", newMessageView

        @messagingLayout.newMessageRegion.show wrappedMessageView

    rightColumnRegion: ->
      footerController = App.request "footer:controller"

      @layout.rightColumnRegion.show footerController.footerView

    getLayoutView: ->
      new Show.Layout

    getMessagingLayoutView: (currentChat) ->
      new Show.MessagingLayout
        model: currentChat

    getMessagesView: (messages, currentUser) ->
      new Show.Messages
        model: currentUser
        collection: messages

    getChatsView: (chats) ->
      new Show.Chats
        collection: chats

    getNewMessageView: (chat, currentUser) ->
      new Show.NewMessageLayout
        model: chat
        currentUser: currentUser

    getChatInfoView: (participant) ->
      new Show.ChatInfo
        model: participant
