@Omega.module "ChatApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: 'chat/show/layout'

    regions:
      chatsRegion: '#chats-region'
      messagingRegion: '#messaging-region'
      rightColumnRegion: '.right-column-region'

  class Show.MessagingLayout extends App.Views.Layout
    getTemplate: ->
      unless @model.isNew()
        'chat/show/_messaging_layout'
      else
        'chat/show/_empty_messaging_layout'
    className: 'col-lg-14 col-md-12'

    regions:
      chatInfoRegion: '#chat-info-region'
      messagesRegion: '#messages-region'
      newMessageRegion: '#new-message-region'

    behaviors:
      Scrollable:
        selector: '.message-content.scrollable'

  class Show.ChatInfo extends App.Views.ItemView
    template: 'chat/show/_chat_info'
    className: 'message-from'

  class Show.EmptyChats extends App.Views.ItemView
    template: 'chat/show/_empty_chats'

  class Show.Chat extends App.Views.ItemView
    template: 'chat/show/_chat'

    className: ->
      @getClassName()

    modelEvents:
      'change:messages' : 'render'

    triggers:
      'click' : 'chat:clicked'

    initialize: ->
      messages = @model.get('messages')
      lastMessage = messages.at(messages.length - 1)
      @listenTo lastMessage.get('crossParticipant'), 'change:last_seen_message_id', @render
      @listenTo lastMessage.get('participant'), 'change:last_seen_message_id', @render

    getClassName: ->
      name = 'inbox-item'
      name += ' active' if @model.get('current') == true
      name

    onRender: ->
      @$el.attr 'class', _.result(this, 'className')

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        isSeen: =>
          @model.lastMessage().isSeen()

  class Show.Chats extends App.Views.CompositeView
    template: 'chat/show/_chats'
    className: 'col-lg-5 col-md-6'
    childView: Show.Chat
    childViewContainer: '.inbox-items'
    emptyView: Show.EmptyChats

    behaviors:
      Scrollable:
        selector: '.inbox-side-box .scrollable'

    ui:
      composeBtn: '.bb-compose-btn'

    triggers:
      'click @ui.composeBtn' : 'new:message:button:clicked'

  class Show.MessageBody extends App.Views.ItemView
    template: 'chat/show/_message_body'

  class Show.Attachment extends App.Shared.Views.Attachment

  class Show.Attachments extends App.Views.CollectionView
    childView: Show.Attachment

  class Show.MessageLayout extends App.Views.Layout
    template: 'chat/show/_message_layout'
    className: ->
      name = 'message'
      name += ' unread' unless @model.isSeen()
      name

    regions:
      messageBodyRegion: '.message-body-region'
      attachmentsRegion: '.attachments-region'

    initialize: ->
      @listenTo @model.get('crossParticipant'), 'change:last_seen_message_id', @toggleSeenClass

    toggleSeenClass: ->
      if @model.get('crossParticipant').get('last_seen_message_id') >= @model.get('id')
        @$el.removeClass 'unread'
        @$el.find('.icon-reply').addClass 'seen'

    onRender: ->
      @$el.attr 'class', _.result(this, 'className')
      attachments = App.request 'new:attachment:entities', @model.get('attachments')
      messageView = new Show.MessageBody
        model: @model
      App.execute 'when:fetched', attachments, =>
        attachmentsView = new Show.Attachments
          collection: attachments

        @messageBodyRegion.show messageView
        @attachmentsRegion.show attachmentsView

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        isSeen: =>
          @model.isSeen()

  class Show.EmptyMessages extends App.Views.ItemView
    template: 'chat/show/_empty_messages'

  class Show.Messages extends App.Views.CollectionView
    emptyView: Show.EmptyMessages
    childView: Show.MessageLayout

    collectionEvents:
      'parsed' : 'render'

    onAddChild: (view) ->
      if view.model.get('participant').get('user_id') == @model.get('id')
        $('#messages-region').scrollTo(view.$el)

    onAttach: ->
      # TODO: probably could be solved without timeout
      setTimeout (=>
        $('#messages-region').scrollTo('.message:last')
      ), 0

  class Show.NewMessageLayout extends App.Shared.Views.Form
    template: 'chat/show/_new_message_layout'
    modelClassName: 'message'

    ui:
      sendButton: '.bb-message-btn'
      textbox: 'textarea'

    triggers:
      'click @ui.textbox' : 'mark:previous:messages:seen'
      'click @ui.sendButton' : 'create:message:button:clicked'
      'paste textarea' :
        event: 'new:message:body:paste'
        preventDefault: false

    regions:
      attachmentsRegion: '.message-attachments-region'

    behaviors:
      Pasteable: { eventName: "new:message:body:paste", attachableType: 'message' }
      Attachable: { attachableType: 'message', multipartForm: false }

    inputFields: ->
      ['body']

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        currentUser: @getOption('currentUser')
