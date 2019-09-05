@Omega.module "CompanyApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options) ->
      _.extend @, App.Extensions.LiveUpdates

      @layout = @getLayoutView()

      company           = App.request "get:company:entity", options.abbr
      currentUser       = App.request "get:current:user"
      trendingStocks    = App.request "get:trending_stocks:company:entities"
      marketSnapshots   = App.request "get:market_snapshot:company:entities"
      companiesToFollow = App.request "get:user:company:recommendations", currentUser.get('id')
      companyNews       = App.request "get:company_news:entities", options.abbr

      App.execute "when:fetched", [company, companiesToFollow, trendingStocks, companyNews, marketSnapshots], =>
        @setMetaData(company)

        @listenTo @layout, 'destroy', =>
          @unsubscribeFromLiveUpdates()

        @listenTo @layout, 'show', =>
          @leftColumnRegion currentUser, trendingStocks
          # @breakingNewsRegion()
          @middleContainerRegion currentUser, company
          @rightColumnRegion currentUser, companiesToFollow, companyNews, marketSnapshots

          @subscribeToLiveUpdates( _.flatten([company, companiesToFollow.models, trendingStocks.models, marketSnapshots.models]) )
        @show @layout
        @executeExtraFunctions()

    setPageTitle: (company) ->
      App.execute "set:page:title", @getPageTitle(company)

    getPageTitle: (company) ->
      # pricedata            = company.get('quote').pricedata
      # icon                 = if pricedata.change > 0 then "▲" else "▼"
      # roundedLastPrice     = Math.round10(pricedata.last, -2).toFixed(2)
      # roundedChangePercent = if pricedata.changepercent then Math.round10(pricedata.changepercent, -1) else 'n/a'
      # percentInHuman = if roundedChangePercent == 0 then "N/C" else roundedChangePercent
      # "#{company.get('abbr')} : #{roundedLastPrice} #{icon} #{percentInHuman}%"
      "#{company.get('abbr')}: Stock Overview of #{company.get('name')}"

    setPageDescription: (company) ->
      App.execute "set:page:description", @getPageDescription(company)

    getPageDescription: (company) ->
      "Financial Information on #{company.get('name')} #{company.get('abbr')} from stock quotes, charts, financial news, earnings, and investor information"

    setPageKeywords: (company) ->
      App.execute "set:page:keywords", @getPageKeywords(company)

    getPageKeywords: (company) ->
      "#{company.get('abbr')} stock price, #{company.get('abbr')} stock quote, #{company.get('name')} stock price, #{company.get('name')} stock quote"

    setMetaData: (company) ->
      @listenTo company, 'change:quote', =>
        @setPageDescription company
        @setPageKeywords company
      @setPageTitle company
      @setPageDescription company
      @setPageKeywords company

    leftColumnRegion: (currentUser, trendingStocks) ->
      @leftColumnLayoutView = @getLeftColumnLayoutView()

      @listenTo @leftColumnLayoutView, 'show', =>
        # @trendingStocksRegion trendingStocks
        @priceTrackerRegion()
        @navigationBarRegion()

      @layout.leftColumnRegion.show @leftColumnLayoutView

    middleContainerRegion: (currentUser, company) ->
      @middleContainerLayoutView = @getMiddleContainerLayoutView()

      @listenTo @middleContainerLayoutView, 'show', =>
        @companyRegion currentUser, company
        if currentUser.isNew()
          @newUserUIRegion company
        else
          @newPostFormRegion()
        @feedRegion company.attributes.abbr

      @layout.middleContainerRegion.show @middleContainerLayoutView

    getMiddleContainerLayoutView: ->
      new Show.MiddleContainerLayout

    rightColumnRegion: (currentUser, companiesToFollow, companyNews, marketSnapshots) ->
      @rightColumnLayoutView = @getRightColumnLayoutView()

      @listenTo @rightColumnLayoutView, 'show', =>
        @marketSnapshotsRegion marketSnapshots
        @companyNewsRegion companyNews
        if companiesToFollow.length > 0
          @followRecommendationRegion currentUser, companiesToFollow
        @footerRegion()

      @layout.rightColumnRegion.show @rightColumnLayoutView

    getRightColumnLayoutView: ->
      new Show.RightColumnLayout

    marketSnapshotsRegion: (marketSnapshots) ->
      marketSnapshotsView = @getMarketSnapshotsView marketSnapshots

      @listenTo marketSnapshotsView, 'childview:company:link:clicked', (child, args) ->
        App.navigate Routes.company_path(child.model), trigger: true

      @rightColumnLayoutView.marketSnapshotsRegion.show marketSnapshotsView

    getMarketSnapshotsView: (marketSnapshots) ->
      new App.Shared.Views.MarketSnapshots
        collection: marketSnapshots

    companyNewsRegion: (companyNews) ->
      companyNewsView = @getCompanyNewsView(companyNews)

      @listenTo companyNewsView, 'see:more:news:link:clicked', ->
        companyNewsView.ui.seeMoreLink.hide()
        companyNews.page += 1
        companyNews.fetch({ data: {page: companyNews.page}, reset: true })

      @listenTo companyNewsView, 'show', ->
        companyNewsView.applyTimeago()

      @rightColumnLayoutView.companyNewsRegion.show companyNewsView

    getCompanyNewsView: (companyNews) ->
      new Show.CompanyNews
        collection: companyNews

    followRecommendationRegion: (currentUser, companiesToFollow) ->
      followRecommendationView = @getFollowRecommendationView companiesToFollow

      @listenTo followRecommendationView, 'childview:follow:company:button:clicked', (child, args) ->
        args.model.follow(currentUser)

      @listenTo followRecommendationView, 'childview:unfollow:company:button:clicked', (child, args) ->
        args.model.unfollow(currentUser)

      @rightColumnLayoutView.followRecommendationRegion.show followRecommendationView

    getFollowRecommendationView: (companiesToFollow) ->
      new Show.FollowRecommendations
        collection: companiesToFollow

    footerRegion: ->
      footerController = App.request 'footer:controller'
      @rightColumnLayoutView.footerRegion.show footerController.footerView

    trendingStocksRegion: (trendingStocks) ->
      trendingStocksView = @getTrendingStocksView trendingStocks

      @listenTo trendingStocksView, 'childview:company:link:clicked', (child, args) ->
        App.navigate Routes.company_path(child.model), trigger: true

      @leftColumnLayoutView.trendingStocksRegion.show trendingStocksView

    priceTrackerRegion: ->
      priceTrackerView = @getPriceTrackerView()

      @leftColumnLayoutView.priceTrackerRegion.show priceTrackerView

    navigationBarRegion: ->
      navigationBarView = @getNavigationBarView()

      @listenTo navigationBarView, 'childview:navigation:bar:item:clicked', (child, args) ->
        console.log child, args

      @leftColumnLayoutView.navigationBarRegion.show navigationBarView

    getTrendingStocksView: (trendingStocks) ->
      new App.Shared.Views.TrendingStocks
        collection: trendingStocks

    getPriceTrackerView: ->
      new Show.PriceTracker()

    getNavigationBarView: ->
      new Show.NavigationBar
       collection: new Backbone.Collection([
        {title: 'Summary', locked: false},
        {title: 'News', locked: false},
        {title: 'Key Statistics', locked: false},
        {title: 'Options', locked: true},
        {title: 'Earnings', locked: true},
        {title: 'Financial Statements', locked: true},
        {title: 'Analyst Coverage', locked: true},
        {title: 'Tools', locked: true}
      ])

    getLeftColumnLayoutView: ->
      new Show.LeftColumnLayout

    breakingNewsRegion: ->
      breakingNewsView = @getBreakingNewsView()
      @layout.breakingNewsRegion.show breakingNewsView

    getBreakingNewsView: ->
      new Show.BreakingNews

    feedRegion: (abbr) ->
      feedComponent = App.request "components:feed",
        id: abbr
        source: 'company:show'
        feedableType: 'company'
        feedableId: abbr

      feedComponent.viewPromise.done (feedView) =>
        @middleContainerLayoutView.feedRegion.show feedView

    companyRegion: (currentUser, company) ->
      @companyLayoutView = @getCompanyView company
      @attachLiveUpdatesHandler(company)

      @listenTo @companyLayoutView, 'show', ->
        @companyChartRegion company
        @companyTrackRegion currentUser, company

      @middleContainerLayoutView.companyRegion.show @companyLayoutView

    attachLiveUpdatesHandler: (company) ->
      # TODO: Checck event name - most likely it doesn't work
      App.vent.on "company:quote:update:received", (quote) ->
        company.set(quote: quote)

    getCompanyView: (company) ->
      new Show.Company
        model: company

    companyTrackRegion: (currentUser, company) ->
      companyTrackView = @getCompanyTrackView company
      @companyLayoutView.companyTrackRegion.show companyTrackView

      @listenTo companyTrackView, 'follow:button:clicked', (args) ->
        args.model.follow(currentUser)

      @listenTo companyTrackView, 'unfollow:button:clicked', (args) ->
        args.model.unfollow(currentUser)

    getCompanyTrackView: (company) ->
      new Show.CompanyTrack
        model: company

    companyChartRegion: (company) ->
      companyChartView = @getCompanyChartView company
      @companyLayoutView.companyChartRegion.show companyChartView

    getCompanyChartView: (company) ->
      new App.Shared.Views.CompanyChart
        model: company

    newPostFormRegion: ->
      post = App.request "new:post:entity"
      newPostFormView = @getNewPostFormView post
      wrappedView = App.request "form:wrapper", newPostFormView,
        multipart: true
        onFormSuccess: (data) =>
          post = App.request "new:post:entity", data
          newPostFormView.$el.find('textarea').val('')
          @middleContainerLayoutView.feedRegion.currentView.collection.unshift post

      @listenToOnce newPostFormView.model, 'sync:stop', =>
        @newPostFormRegion()
      @middleContainerLayoutView.newPostFormRegion.show wrappedView

    getNewPostFormView: (post) ->
      new Show.NewPostForm
        model: post

    newUserUIRegion: (company) ->
      newUserUIView = @getNewUserUIView company

      @listenTo newUserUIView, 'login:button:clicked', ->
        App.navigate Routes.new_user_session_path(), trigger: true

      @listenTo newUserUIView, 'signup:button:clicked', ->
        App.navigate Routes.signup_path(), trigger: true

      @middleContainerLayoutView.newUserUIRegion.show newUserUIView

    getNewUserUIView: (company) ->
      new App.Shared.Views.NewUserPostFormReplacement
        model: company

    getLayoutView: ->
      new Show.Layout

    executeExtraFunctions: ->

      check_width = (elem) ->
        elem.outerWidth()

      positionate_cols = () ->
        if check_width($('.company-profile .container')) == 970
          left_col_height = $('#left-column-region > div').outerHeight(true)
          $('#right-column-region > div').css top: left_col_height
        else
          $('#right-column-region > div').css top: 0

      $ ->
        $(window).resize ->
          #positionate_cols()
