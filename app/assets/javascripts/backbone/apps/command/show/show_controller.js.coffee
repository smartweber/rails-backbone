@Omega.module 'CommandApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    initialize: ->
      _.extend @, App.Extensions.LiveUpdates

      @layout = @getLayoutView()
      currentUser        = App.request "get:current:user"
      newsArticles       = App.request "get:news:articles"
      channels           = App.request 'get:top:hashtags'
      marketSnapshots    = App.request "get:market_snapshot:company:entities"
      trendingStocks     = App.request 'get:trending_stocks:company:entities'
      followingCompanies = App.request "get:user:following:companies", currentUser.id
      listOfEntities = [currentUser, followingCompanies, newsArticles, channels,
                        trendingStocks, marketSnapshots]

      App.vent.on "new:notification:received", =>
        @setPageTitle()

      App.execute "when:fetched", listOfEntities, =>
        # TODO: bind this implicitly
        @listenTo @layout, 'destroy', =>
          @unsubscribeFromLiveUpdates()

        @listenTo @layout, "show", =>
          @leftColumnRegion currentUser, channels, trendingStocks
          @middleContainerRegion currentUser, followingCompanies
          @rightColumnRegion newsArticles, marketSnapshots

          @subscribeToLiveUpdates( _.flatten([trendingStocks.models, marketSnapshots.models,
                                              followingCompanies.models]) )
        @show @layout
        @executeExtraFunctions()

    pageTitle: ->
      notificationsCount = App.request "get:notifications:count"
      baseTitle = "Stockharp"
      if notificationsCount > 0
        baseTitle = s(baseTitle).insert(0, "#{notificationsCount} ").value()
      baseTitle

    leftColumnRegion: (currentUser, channels, trendingStocks) ->
      @leftColumnLayoutView = @getLeftColumnLayoutView()

      @listenTo @leftColumnLayoutView, 'show', =>
        @profileRegion currentUser
        @trendingStocksRegion trendingStocks
        if channels.length > 0
          @trendingChannelsRegion channels

      @layout.leftColumnRegion.show @leftColumnLayoutView

    profileRegion: (currentUser) ->
      profileView = @getProfileView currentUser

      @listenTo profileView, 'posts:link:clicked', ->
        App.navigate Routes.user_path(currentUser), trigger: true

      @listenTo profileView, 'section:link:clicked', (e) ->
        e.preventDefault()
        e.stopPropagation()
        App.navigate $(e.target).attr('href'), trigger: true

      @leftColumnLayoutView.profileRegion.show profileView

    trendingStocksRegion: (trendingStocks) ->
      trendingStocksView = @getTrendingStocksView trendingStocks

      @listenTo trendingStocksView, 'childview:company:link:clicked', (child, args) ->
        App.navigate Routes.company_path(child.model), trigger: true

      @leftColumnLayoutView.trendingStocksRegion.show trendingStocksView

    trendingChannelsRegion: (channels) ->
      trendingChannelsView = @getTrendingChannelsView channels

      @listenTo trendingChannelsView, 'childview:channel:link:clicked', (child) ->
        App.navigate Routes.hashtag_path(child.model), trigger: true

      @leftColumnLayoutView.trendingChannelsRegion.show trendingChannelsView

    breakingNewsRegion: ->
      breakingNewsComponent = App.execute "render:components:breaking_news",
        region: @middleContainerLayoutView.breakingNewsRegion

    middleContainerRegion: (currentUser, followingCompanies) ->
      @middleContainerLayoutView = @getMiddleContainerLayoutView()

      @listenTo @middleContainerLayoutView, 'show', =>
        @breakingNewsRegion()
        @commandTabsRegion followingCompanies
        @newPostFormRegion currentUser
        @feedRegion currentUser

      @layout.middleContainerRegion.show @middleContainerLayoutView

    commandTabsRegion: (followingCompanies) ->
      @commandTabsWidgetView = @getCommandTabsWidgetView()

      @listenTo @commandTabsWidgetView, 'show', =>
        @newsRegion()
        @radarRegion followingCompanies
        @marketMoversRegion()
        @mostVolumeRegion()

      @middleContainerLayoutView.commandTabsRegion.show @commandTabsWidgetView

    newsRegion: ->
      App.request "components:carousel", @commandTabsWidgetView.newsRegion

    radarRegion: (followingCompanies) ->
      @radarView = @getRadarView followingCompanies

      @listenTo @radarView, 'region:company:chart:clicked', (child) ->
        App.navigate Routes.company_path(child.model.get('abbr')), trigger: true

      @listenTo @radarView, 'show', =>
        _.each @radarView.groupedCollection, (companies, index) =>
          tilesCollectionView = @getTilesCollectionView(new App.Entities.CompanyCollection companies)
          @radarView.getRegion(@radarView.pageRegionsNames[index]).show tilesCollectionView
        if followingCompanies.length > 0
          @companiesListRegion followingCompanies

      @commandTabsWidgetView.radarRegion.show @radarView

    companiesListRegion: (followingCompanies) ->
      companiesListView = @getCompaniesListView followingCompanies
      @radarView.companiesListRegion.show companiesListView

    marketMoversRegion: ->
      marketMoversView = @getMarketMoversView()
      @commandTabsWidgetView.marketMoversRegion.show marketMoversView

    mostVolumeRegion: ->
      mostVolumeView = @getMostVolumeView()
      @commandTabsWidgetView.mostVolumeRegion.show mostVolumeView

    newPostFormRegion: (currentUser) ->
      post = App.request "new:post:entity"
      newPostFormView = @getNewPostFormView post
      wrappedView = App.request "form:wrapper", newPostFormView,
        multipart: true
        onFormSuccess: (data) =>
          post = App.request "new:post:entity", data
          newPostFormView.$el.find('textarea').val('')
          currentUser.set 'ideas_count', currentUser.get('ideas_count') + 1
          @middleContainerLayoutView.feedRegion.currentView.collection.unshift post

      @listenToOnce newPostFormView.model, 'sync:stop', =>
        @newPostFormRegion currentUser

      @middleContainerLayoutView.newPostFormRegion.show wrappedView

    feedRegion: (currentUser) ->
      feedComponent = App.request "components:feed",
        source: 'feed:show'
        feedableType: 'command'
        feedableId: currentUser.id

      feedComponent.viewPromise.done (feedView) =>
        @middleContainerLayoutView.feedRegion.show feedView

    rightColumnRegion: (newsArticles, marketSnapshots) ->
      @rightColumnLayoutView = @getRightColumnLayoutView()

      @listenTo @rightColumnLayoutView, 'show', =>
        @marketSnapshotsRegion marketSnapshots
        @marketHeadlinesRegion newsArticles
        @followRecommendationRegion()

      @layout.rightColumnRegion.show @rightColumnLayoutView

    marketSnapshotsRegion: (marketSnapshots) ->
      marketSnapshotsView = @getMarketSnapshotsView marketSnapshots
      @rightColumnLayoutView.marketSnapshotsRegion.show marketSnapshotsView

    marketHeadlinesRegion: (newsArticles) ->
      marketHeadlinesView = @getMarketHeadlinesView newsArticles

      _.each ['next:page:link:clicked', 'prev:page:link:clicked'], (event) =>
        @listenTo marketHeadlinesView, event, ->
          marketHeadlinesView.toggleLinks()
          newsArticles.page += if _.isEmpty(event.match(/next/)) then -1 else 1
          newsArticles.fetch({ data: {page: newsArticles.page}, reset: true })

      @rightColumnLayoutView.marketHeadlinesRegion.show marketHeadlinesView

    followRecommendationRegion: ->
      followRecommendationView = @getFollowRecommendationView()
      @rightColumnLayoutView.followRecommendationRegion.show followRecommendationView

    getLayoutView: ->
      new Show.Layout

    getCommandTabsWidgetView: ->
      new Show.CommandTabsWidget

    getRadarView: (followingCompanies) ->
      new Show.Radar
        collection: followingCompanies

    getTilesCollectionView: (companies) ->
      new App.Shared.Views.Tiles
        collection: companies

    getNewPostFormView: (post) ->
      new Show.NewPostForm
        model: post

    getMarketSnapshotsView: (marketSnapshots) ->
      new App.Shared.Views.MarketSnapshots
        collection: marketSnapshots

    getMarketHeadlinesView: (newsArticles) ->
      new App.Shared.Views.MarketHeadlines
        collection: newsArticles

    getFollowRecommendationView: ->
      new App.Shared.Views.UserFollowRecommendations

    getRightColumnLayoutView: ->
      new Show.RightColumnLayout

    getMiddleContainerLayoutView: ->
      new Show.MiddleContainerLayout

    getTrendingStocksView: (trendingStocks) ->
      new App.Shared.Views.TrendingStocks
        collection: trendingStocks

    getTrendingChannelsView: (channels) ->
      new Show.TrendingChannels
        collection: channels

    getProfileView: (currentUser) ->
      new App.Shared.Views.Profile
        model: currentUser

    getLeftColumnLayoutView: ->
      new Show.LeftColumnLayout

    getMarketMoversView: ->
      new Show.MarketMovers

    getMostVolumeView: ->
      new Show.MostVolume

    getCompaniesListView: (followingCompanies) ->
      new Show.RadarList
        collection: followingCompanies

    # TODO:
    executeExtraFunctions: ->
      $ ->
        $('[data-toggle="tooltip"]').tooltip()
        $('[data-toggle="popover"]').popover()
        #enscroll instance
        $('a[data-toggle="pill"]').on 'shown.bs.tab', (e) ->
          activePane = $(e.target).attr('href')
          $(activePane).find('.scroll-pane').enscroll 'destroy'
          $(activePane).find('.scroll-pane').enscroll
            showOnHover: false
            verticalTrackClass: 'track3'
            verticalHandleClass: 'handle3'
            easingDuration: 100
          return
