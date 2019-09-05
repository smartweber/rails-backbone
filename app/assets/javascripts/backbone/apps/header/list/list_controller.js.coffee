@Omega.module "HeaderApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base
    # TODO: set instead of setting this manually extend from class that has it set
    disableTitleAutoSetting: true

    initialize: ->
      currentUser = App.request "get:current:user"
      instantMessages = App.request "get:instant-message:list"

      App.execute "when:fetched", currentUser, =>
        @layout = @getLayoutView currentUser

        @listenTo @layout, 'logo:link:clicked', (args) ->
          redirectPath = unless currentUser.isNew()
            Routes.command_path()
          else
            Routes.root_path()
          App.navigate redirectPath, trigger: true

        @listenTo @layout, 'region:notification:link:clicked', (regionView, child, event) ->
          href = $(event.currentTarget).attr('href')
          regionView.collection.markSeen(child.model).done =>
            unless href == '#' or href == undefined
              App.navigate href, trigger: true

        if currentUser.isNew()
          @listenTo @layout, 'show', =>
            @newUserUIRegion(currentUser)
            @flashMessageRegion instantMessages
            @modalRegion()

        else
          notifications = {}
          for notifications_obj in currentUser.get('notifications')
            notifications[notifications_obj.type] = App.request "new:notification:entities", notifications_obj.notifications

          App.vent.on "new:notification:received", (notification_details) =>
            notification = App.request "new:notification:entity", notification_details
            _.each App.Entities.Notification.prototype.defaults.types, (values, key) ->
              notifications[key].addOrReplace(notification) if _.contains(values, notification.get('type'))

          App.execute "when:fetched", [notifications, instantMessages], =>
            App.reqres.setHandler "get:notifications:count", =>
              total = 0
              _.forEach _.values(notifications), (collection) ->
                total += collection.length
              total

            @listenTo @layout, 'show', =>
              @messageRegion notifications.message
              @commonRegion notifications.common
              @stockRegion notifications.stock
              @profileMenuRegion currentUser
              @flashMessageRegion instantMessages
              @modalRegion()

        @show @layout

    newUserUIRegion: (newUser) ->
      notAtLoginPage = _.isEmpty(Backbone.history.fragment.match(/^login\/?/))
      if notAtLoginPage
        newUser.url = Routes.new_user_session_path()
        resultingView = @getUnsignedUserFormView(newUser)
        @listenTo resultingView, 'signup:button:clicked', ->
          App.navigate Routes.signup_path(), trigger: true
        @listenTo resultingView, 'login:button:clicked', ->
          App.navigate Routes.new_user_session_path(), trigger: true
      else
        resultingView = @getNewUserLoginView()
        @listenTo resultingView, 'signup:button:clicked', ->
          App.navigate Routes.signup_path(), trigger: true

      @layout.newUserUIRegion.show resultingView

    messageRegion: (mNotifications) ->
      messageView = @getMessageView mNotifications
      @listenTo messageView, 'see:more:link:clicked', ->
        App.navigate Routes.messages_path(), trigger: true

      @layout.messageRegion.show messageView

    modalRegion: ->
      modalView = @getModalView()

      @listenTo modalView, 'modal:displayed', ->
        App.execute "websocket:disconnect"

      @listenTo modalView, 'reload:page', ->
        location.reload()

      App.vent.on "visibility:change", (visibility) =>
        if visibility == "hidden"
          modalView.restartVisibilityTimeout()
        else
          modalView.clearVisibilityTimeout()

      @layout.modalRegion.show modalView

    commonRegion: (cNotifications) ->
      commonView = @getCommonView cNotifications
      @layout.commonRegion.show commonView

    stockRegion: (sNotifications) ->
      stockView = @getStockView sNotifications
      @layout.stockRegion.show stockView

    profileMenuRegion: (currentUser) ->
      profileMenuView = @getProfileMenuView currentUser

      @listenTo profileMenuView, 'signout:link:clicked', ->
        App.vent.trigger 'logout:current:user'

      @listenTo profileMenuView, 'messages:link:clicked', ->
        App.navigate Routes.messages_path(), trigger: true

      @listenTo profileMenuView, 'settings:link:clicked', ->
        App.navigate Routes.settings_path(), trigger: true

      @layout.profileMenuRegion.show profileMenuView

    flashMessageRegion: (messages=[]) ->
      flashMessagesView = @getFlashMessagesView messages

      @listenTo flashMessagesView, 'childview:flash:message:clicked', (child) ->
        child.model.destroy()

      @layout.flashMessageRegion.show flashMessagesView

    getLayoutView: (currentUser) ->
      new List.Header
        model: currentUser

    getMessageView: (mNotifications) ->
      new List.MessageNotifications
        collection: mNotifications

    getCommonView: (cNotifications) ->
      new List.CommonNotifications
        collection: cNotifications

    getStockView: (sNotifications) ->
      new List.StockNotifications
        collection: sNotifications

    getProfileMenuView: (currentUser) ->
      new List.ProfileMenu
        model: currentUser

    getUnsignedUserFormView: (newUser) ->
      new List.UnsignedUserForm
        model: newUser

    getNewUserLoginView: ->
      new List.NewUserLogin

    getFlashMessagesView: (messages) ->
      new List.FlashMessages
        collection: messages

    getModalView: ->
      new List.ModalView()
