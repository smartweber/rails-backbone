@Omega.module 'ChannelApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    initialize: (options) ->
      @layout = @getLayoutView()
      currentUser = App.request "get:current:user"

      App.execute "when:fetched", currentUser, =>
        @listenTo @layout, 'show', =>
          @leftColumnRegion currentUser
          @middleColumnRegion options.id
          @rightColumnRegion()

        @show @layout

    leftColumnRegion: (currentUser) ->
      @leftColumnLayoutView = @getLeftColumnLayoutView()
      @listenTo @leftColumnLayoutView, 'show', =>
        @profileRegion currentUser
      @layout.leftColumnRegion.show @leftColumnLayoutView

    profileRegion: (currentUser) ->
      profileView = @getProfileView currentUser
      @leftColumnLayoutView.profileRegion.show profileView

    middleColumnRegion: (channelName) ->
      @middleColumnLayoutView = @getMiddleColumnLayoutView channelName
      @listenTo @middleColumnLayoutView, 'show', =>
        @feedRegion channelName
      @layout.middleColumnRegion.show @middleColumnLayoutView

    feedRegion: (channelName) ->
      feedComponent = App.request "components:feed",
        id: channelName
        source: 'channel:show'
        feedableType: 'channel'
        feedableId: channelName

      feedComponent.viewPromise.done (feedView) =>
        @middleColumnLayoutView.feedRegion.show feedView

    rightColumnRegion: ->
      @rightColumnLayoutView = @getRightColumnLayoutView()
      @listenTo @rightColumnLayoutView, 'show', =>
        @footerRegion()
      @layout.rightColumnRegion.show @rightColumnLayoutView

    footerRegion: ->
      footerController = App.request 'footer:controller'
      @rightColumnLayoutView.footerRegion.show footerController.footerView

    getLayoutView: ->
      new Show.Layout

    getLeftColumnLayoutView: (currentUser) ->
      new Show.LeftColumnLayout

    getProfileView: (currentUser) ->
      new App.Shared.Views.Profile
        model: currentUser

    getMiddleColumnLayoutView: (channelName) ->
      new Show.MiddleColumnLayout
        channelName: channelName

    getRightColumnLayoutView: ->
      new Show.RightColumnLayout
