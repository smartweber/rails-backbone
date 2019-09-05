@Omega.module "Components.WebSocket", (WebSocket, App, Backbone, Marionette, $, _) ->

  class WebSocket.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options) ->
      @websocket = App.request "new:websocket:entity", options.user
      currentUser = App.request "get:current:user"

      App.execute 'when:fetched', currentUser, =>
        App.vent.on "create:message:button:clicked", (message, chatId) =>
          @websocket.publish Routes.api_chat_messages_path(chatId), { message: message }

        App.vent.on "new:subscription:received", (subscriptionDetails) =>
          @websocket.subscribe subscriptionDetails.subscription_path, "new:message:received"
          App.vent.trigger "new:chat:received", subscriptionDetails.chat

        App.commands.setHandler "websocket:disconnect", () =>
          @dumpSubscriptions()
          @websocket.disconnect()

        App.commands.setHandler "websocket:subscribe:user:to:notifications", =>
          @websocket.subscribe Routes.notifications_api_user_path(currentUser.id), "new:notification:received"

        App.commands.setHandler "websocket:subscribe:to:breaking_news", =>
          @websocket.subscribe Routes.api_subscriptions_breaking_news_path(), "update:breaking_news:received"

        App.commands.setHandler "websocket:subscribe:to:trending_stream", =>
          @websocket.subscribe Routes.api_subscriptions_trending_stream_path(), "update:trending_stream:received"

        App.commands.setHandler "websocket:companies:live_update:subscribe", (companies) =>
          uniqCompanies = _.uniq companies, (company) ->
            company.get('id')
          _.each uniqCompanies, (company) =>
            abbr = company.get('abbr')
            @websocket.subscribe Routes.api_subscriptions_company_path(abbr), "company:quote:update:received:#{abbr}"

        App.commands.setHandler "websocket:subscribe:to:feed", (feedableType, feedableId) =>
          @websocket.subscribe Routes.api_subscriptions_stream_path(feedableId, feedableType), "feeds:#{feedableType}:#{feedableId}:update:received"

        App.commands.setHandler "websocket:companies:live_update:unsubscribe:all", =>
          subscriptions = _.filter @websocket.client._channels._channels, (channel) ->
            channel.id.match(/\/api\/subscriptions\/c\/[a-zA-Z.]+/)
          _.each subscriptions, (subscription) =>
            @websocket.unsubscribe subscription.id

        App.commands.setHandler "websocket:chats:subscribe", (chat_ids) =>
          # this channel is used for all new subscriptions that's user not subscribed(yet) to
          @websocket.subscribe Routes.subscriptions_api_user_path(currentUser.id), "new:subscription:received"
          _.each chat_ids, (id, index, list) =>
            chatPath = Routes.api_chat_messages_path(id)
            unless @websocket.hasSubscription chatPath
              @websocket.subscribe chatPath, "new:message:received"

    dumpSubscriptions: ->
      @dumpedSubscriptions = @websocket.activeChannels
      @websocket.activeChannels = []

    restoreSubscriptions: ->
      _.each @dumpedSubscriptions, (subscription) =>
        @websocket.subscribe subscription.channel, subscription.eventName

  App.reqres.setHandler "new:websocket:wrapper", (user) ->
    new WebSocket.Controller
      user: user
