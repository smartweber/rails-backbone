@Omega.module "HomeApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Controller extends App.Controllers.Base
    initialize: ->
      _.extend @, App.Extensions.LiveUpdates

      @layout     = @getLayoutView()
      topChannels = App.request('get:top:hashtag')
      App.execute "when:fetched", topChannels, =>
        topChannelFeed = if topChannels.models.length > 0
          App.request "channel:show:feed", 1, topChannels.models[0].get('word')
        else
          App.request "feed:entity"
        trendingStreamFeed = App.request 'trending:stock:feed'
        mustReadNews       = App.request "get:top:article:entities"
        marketHeadlines    = App.request "get:market_headline:entities"
        listOfEntities     = [topChannels, topChannelFeed, trendingStreamFeed,
                               mustReadNews, marketHeadlines]

        App.execute "when:fetched", listOfEntities, =>
          @setMetaData()
          @listenTo @layout, 'destroy', =>
            @unsubscribeFromLiveUpdates()

          @listenTo @layout, 'show', =>
            @leftColumnRegion topChannels.models[0], topChannelFeed.get('posts'), marketHeadlines
            @rightColumnRegion mustReadNews, trendingStreamFeed.get('posts')
            @signupFooterLinksRegion()
          @show @layout

    leftColumnRegion: (topChannel, topChannelItems, marketHeadlines) ->
      @leftColumnLayoutView = @getLeftColumnLayoutView()

      @listenTo @leftColumnLayoutView, 'show', =>
        @marketIndexesRegion()
        @carouselNewsRegion()
        @breakingNewsRegion()
        @trendingChannelRegion topChannel, topChannelItems
        @trendingStocksRegion()
        @marketHeadlinesRegion marketHeadlines

      @layout.leftColumnRegion.show @leftColumnLayoutView

    carouselNewsRegion: ->
      App.request "components:carousel", @leftColumnLayoutView.carouselNewsRegion

    breakingNewsRegion: ->
      App.execute "render:components:breaking_news",
        region: @leftColumnLayoutView.breakingNewsRegion

    trendingChannelRegion: (topChannel, topChannelItems)->
      trendingChannelView = @getTrendingChannelView topChannel, topChannelItems

      @listenTo trendingChannelView, 'region:post:tag:clicked', (event) ->
        App.navigate $(event.target).attr('href'), trigger: true

      # @leftColumnLayoutView.trendingChannelRegion.show trendingChannelView

    trendingStocksRegion: ->
      App.request 'components:trending_stock', @leftColumnLayoutView.trendingStocksRegion

    rightColumnRegion: (mustReadNews, trendingStreamItems) ->
      @rightColumnLayoutView = @getRightColumnLayoutView()

      @listenTo @rightColumnLayoutView, 'show', =>
        @newsRegion mustReadNews
        @trendingStreamRegion()

      @layout.rightColumnRegion.show @rightColumnLayoutView

    marketIndexesRegion: ->
      App.request 'components:market_index', @leftColumnLayoutView.marketIndexesRegion

    newsRegion: (mustReadNews) ->
      newsView = @getNewsView mustReadNews

      @listenTo newsView, 'region:news_item:clicked', (childview) =>
        App.navigate childview.$el.find('a:first').attr('href'), trigger: true

      @listenTo newsView, 'show', =>
        if newsView.$childViewContainer
          newsView.$childViewContainer.find("time.timeago").timeago()

      @rightColumnLayoutView.newsRegion.show newsView

    trendingStreamRegion: ->
      App.request "components:trending_stream", @rightColumnLayoutView.trendingStreamRegion

    marketHeadlinesRegion: (marketHeadlines) ->
      marketHeadlinesView = @getMarketHeadlinesView marketHeadlines
      @leftColumnLayoutView.marketHeadlinesRegion.show marketHeadlinesView

    signupFooterLinksRegion: ->
      signupFooterLinksView = @getSignupFooterLinksView()

      @listenTo signupFooterLinksView, 'login:button:clicked', ->
        App.navigate Routes.new_user_session_path(), trigger: true

      @listenTo signupFooterLinksView, 'signup:button:clicked', ->
        App.navigate Routes.signup_path(), trigger: true

      @layout.signupFooterLinksRegion.show signupFooterLinksView

    setMetaData: ->
      @setPageKeywords()

    setPageKeywords: ->
      App.execute "set:page:keywords", @getPageKeywords()

    getPageKeywords: ->
      "Stockharp, financial news, stock market, stock quotes"

    getMarketHeadlinesView: (marketHeadlines) ->
      new List.MarketHeadlines
        collection: marketHeadlines

    getSignupFooterLinksView: ->
      new List.SignupFooterLinks

    getRightColumnLayoutView: ->
      new List.RightColumnLayout

    getTilesCollectionView: (companies) ->
      new App.Shared.Views.Tiles
        collection: companies

    getNewsView: (mustReadNews) ->
      new List.News
        collection: mustReadNews

    getLeftColumnLayoutView: ->
      new List.LeftColumnLayout

    getTrendingChannelView: (topChannel, topChannelItems) ->
      new List.TrendingChannel
        model: topChannel
        collection: topChannelItems

    getChartView: (company) ->
      new App.Shared.Views.CompanyChart
        model: company

    getLayoutView: ->
      new List.Layout
