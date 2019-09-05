@Omega = do (Backbone, Marionette) ->

  App = new Marionette.Application

  App.on "before:start", (options) ->
    @csrfToken   = $('meta[name=csrf-token]').attr('content')
    @fayePath    = options.fayePath
    @environment = options.environment
    if options.flash
      App.execute "add:instant-messages", options.flash

    App.execute "set:current:user", options.currentUser

  App.rootRoute = Routes.root_path()

  Marionette.Behaviors.behaviorsLookup = ->
    App

  App.addRegions
    topRegion: '#top-region'

  App.reqres.setHandler "top:region", ->
    App.topRegion

  App.commands.setHandler "add:instant-messages", (attributes) ->
    if _.isString(attributes) then attributes =
      type: "warning"
      message: attributes
    App.request "add:instant-message:entity", attributes

  App.commands.setHandler "reset:instant-messages", ->
    App.request "reset:instant-message:list"

  App.commands.setHandler "set:page:title", (title) ->
    document.title = title

  App.commands.setHandler "set:page:keywords", (keywordsStr) ->
    $('meta[name="keywords"]').attr('content', keywordsStr)

  App.commands.setHandler "set:page:description", (description) ->
    $('meta[name="description"]').attr('content', description)

  App.reqres.setHandler "get:current:user", ->
    App.currentUser

  App.vent.on "logout:current:user", ->
    App.navigate(Routes.destroy_user_session_path(), trigger: true)

  App.commands.setHandler "reset:current:user", ->
    App.currentUser.clear()

  App.commands.setHandler "set:current:user", (attributes) ->
    if App.currentUser?
      App.currentUser.set attributes
    else
      App.currentUser = App.request "new:user:entity", attributes
    App.webSocketWrapper = App.request "new:websocket:wrapper", App.currentUser

  App.reqres.setHandler "get:current:user:websocket", ->
    App.webSocketWrapper

  App.on "start", (options) ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()
  App
