@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.WebSocket extends App.Entities.Model
    initialize: ->
      @host = App.fayePath.host
      @port = App.fayePath.port
      @activeChannels = []
      @connect()
      unless @get('user').isNew()
        @listenTo @get('user'), 'destroy', =>
          @disconnect()

    connect: ->
      unless @client and @client._state != 0
        protocol = if App.environment == 'production' then 'https' else 'http'
        @client = new Faye.Client("#{protocol}://#{@host}:#{@port}/faye", {retry: 10})
        @client.addExtension outgoing: (message, callback) ->
          message.ext = message.ext or {}
          message.ext.csrfToken = App.csrfToken
          callback message
        unless @get('user').isNew()
          App.execute "websocket:subscribe:user:to:notifications"
        App.execute "websocket:subscribe:to:breaking_news"

    disconnect: ->
      @client.disconnect()

    publish: (channel, message) ->
      publication = @client.publish channel, message, { deadline: 5, attempts: 3 }
      publication.then (->
        console.log 'success'
      ), (error) ->
        console.log 'error ' + error.message

    subscribe: (channel, triggerEventName) ->
      @client.subscribe(channel, (message) =>
        App.vent.trigger triggerEventName, message
      ).then =>
        @activeChannels.push
          channel: channel
          eventName: triggerEventName

    unsubscribe: (channel) ->
      @client.unsubscribe(channel, =>
        @activeChannels = _.reject @activeChannels, (el) =>
          el.channel == channel
      , @)

    hasSubscription: (channel) ->
      @client._channels.hasSubscription channel

  API =
    newWebSocket: (user) ->
      webSocket = new Entities.WebSocket user: user
      webSocket

  App.reqres.setHandler "new:websocket:entity", (user) ->
    API.newWebSocket user
