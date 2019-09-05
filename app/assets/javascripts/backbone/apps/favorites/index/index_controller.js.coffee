@Omega.module "FavoritesApp.Index", (Index, App, Backbone, Marionette, $, _) ->

  class Index.Controller extends App.Controllers.Base
    initialize: (options) ->
      @layout = @getLayoutView()
      user = App.request "get:current:user"

      App.execute "when:fetched", user, =>
        @listenTo @layout, 'show', =>
          @userRegion user
          @feedRegion user
          @modalRegion

        @show @layout

    feedRegion: (user) ->
      feedComponent = App.request "components:feed",
        source: 'user:favorite'
        maxCommentsPerPost: 0
        # intentionally left without live-refresh

      feedComponent.viewPromise.done (feedView) =>
        @layout.feedRegion.show feedView

    userRegion: (user) ->
      userRegion = @getUserInfoView user

      @layout.userRegion.show userRegion

    modalRegion: ->
      modalView = @getModalView()

      @layout.modalRegion.show

    getLayoutView: ->
      new Index.Layout

    getUserInfoView: (user) ->
      new Index.UserInfo
        model: user

    getModalView: ->
      new Index.Modal
