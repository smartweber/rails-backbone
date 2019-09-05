@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Notification extends App.Entities.Model
    urlRoot: -> Routes.api_notifications_path()
    paramRoot: 'notification'

    defaults:
      types:
        message: ["new_message"]
        common: ["new_follower", "post_liked", "new_comment", "new_mention"]
        stock: ["stock_news"]

    typeIsNewMessage: ->
      _.contains @get('types').message, @get('type')

  class Entities.NotificationCollection extends App.Entities.Collection
    model: Entities.Notification

    url: ->
      Routes.api_notifications_path()

    getNotifiableUniquenessAttributeName: (notification) ->
      switch
        when notification.typeIsNewMessage() then 'chat_id'
        else 'id'

    addOrReplace: (notification) ->
      attributeName = @getNotifiableUniquenessAttributeName notification
      replaceableID = notification.get('notifiable')[attributeName]
      sameEventNotification = @find (n) ->
        n.get('notifiable')[attributeName] == replaceableID
      @remove(sameEventNotification) if sameEventNotification?
      @add notification

    markSeen: (model) ->
      $.ajax
        url: Routes.api_notification_path(model.get('id'))
        dataType: 'json'
        type: 'PUT'
        data: { notification: { id: model.get('id'), seen: true } }
        success: =>
          @remove model

  API =
    newNotificationCollection: (notifications) ->
      notifications = new Entities.NotificationCollection notifications
      notifications

    newNotification: (attributes) ->
      notification = new Entities.Notification attributes
      notification

  App.reqres.setHandler "new:notification:entities", (notifications) ->
    API.newNotificationCollection notifications

  App.reqres.setHandler "new:notification:entity", (attributes) ->
    API.newNotification attributes
