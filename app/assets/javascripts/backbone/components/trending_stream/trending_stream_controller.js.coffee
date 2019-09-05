@Omega.module "Components.TrendingStream", (TrendingStream, App, Backbone, Marionette, $, _) ->

  class TrendingStream.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options) ->
      feed = App.request 'trending:stock:feed'

      @region = options.region
      @showLoadingView()

      App.execute 'when:fetched', feed, =>
        trendingStreamItems = feed.get('posts')
        # TODO: should be preset before fetching
        trendingStreamItems.comparator = (model) ->
          return -model.get('id')
        @trendingStreamView = @getTrendingStreamView trendingStreamItems
        @listenTo @trendingStreamView, 'region:post:tag:clicked', (event) ->
          App.navigate $(event.target).attr('href'), trigger: true

        App.vent.on "update:trending_stream:received", (posts) =>
          trendingStreamItems.add(posts)
          trendingStreamItems.remove(trendingStreamItems.models.slice(9, trendingStreamItems.length))

        App.execute "websocket:subscribe:to:trending_stream"

        @region.show @trendingStreamView
      , =>
        @showEmptyView()

    getTrendingStreamView: (trendingStreamItems) ->
      new TrendingStream.Stream
        collection: trendingStreamItems

    showLoadingView: ->
      loadingView = @getLoadingView()
      @region.show loadingView

    getLoadingView: ->
      new TrendingStream.Loading

    showEmptyView: ->
      emptyView = @getEmptyView()
      @region.show emptyView

    getEmptyView: ->
      new TrendingStream.Empty

  App.reqres.setHandler "components:trending_stream", (region) ->
    new TrendingStream.Controller
      region: region
