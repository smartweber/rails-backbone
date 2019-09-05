@Omega.module "CompanyApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: 'company/show/layout'

    regions:
      leftColumnRegion: '#left-column-region'
      breakingNewsRegion: '#breaking-news-region'
      middleContainerRegion: '#middle-container-region'
      rightColumnRegion: '#right-column-region'

  class Show.LeftColumnLayout extends App.Views.Layout
    template: 'company/show/_left_column_layout'
    className: 'col-sm-6 col-lg-5'

    regions:
      trendingStocksRegion: '#trending-stocks-region'
      priceTrackerRegion: '#price-tracker-region'
      navigationBarRegion: '#navigation-bar-region'

  class Show.MiddleContainerLayout extends App.Views.Layout
    template: 'company/show/_middle_container_layout'
    className: 'col-sm-18 col-lg-14'

    regions:
      feedRegion: '#feed-region'
      companyRegion: '#company-region'
      newUserUIRegion: '#new-user-ui-region'
      newPostFormRegion: '#new-post-region'

  class Show.RightColumnLayout extends App.Views.Layout
    template: 'company/show/_right_column_layout'
    className: 'col-sm-18 col-sm-push-6 col-lg-5 col-lg-push-0'

    regions:
      marketSnapshotsRegion: '#market-snapshots-region'
      companyNewsRegion: '#company-news-region'
      followRecommendationRegion: '#follow-recommendation-region'
      footerRegion: '#footer-region'

  class Show.NewPostForm extends App.Shared.Views.NewPostForm
    events:
      'focus @ui.textArea' : 'prependCashtag'
      'keyup @ui.textArea' : 'onTextAreaKeyup'

    prependCashtag: ->
      if $(@ui.textArea).val() == ""
        cashtag = App.request "current:page:cashtag"
        $(@ui.textArea).val("$#{cashtag.toUpperCase()} ")

  class Show.CompanyNewsItem extends App.Views.ItemView
    template: 'company/show/_company_news_item'
    className: 'list-group-item'
    tagName: 'a'
    attributes: ->
      'href': @model.get('url')
      'target': '_blank'

  class Show.CompanyNews extends App.Views.CompositeView
    template: 'company/show/_company_news'
    className: 'list-group list-well list-headlines'
    childView: Show.CompanyNewsItem
    childViewContainer: '.bb-news-items'

    ui:
      seeMoreLink: '.bb-see-more-news'

    triggers:
      'click @ui.seeMoreLink' : 'see:more:news:link:clicked'

    onRenderCollection: ->
      @applyTimeago()

    applyTimeago: ->
      @$el.find("time.timeago").timeago()

  class Show.FollowRecommendation extends App.Views.ItemView
    template: 'company/show/_follow_recommendation'
    tagName: 'li'
    className: 'list-group-item'

    ui:
      followBtn: '.bb-follow-company-btn'
      unfollowBtn: '.bb-unfollow-company-btn'

    triggers:
      'click @ui.followBtn'   : 'follow:company:button:clicked'
      'click @ui.unfollowBtn' : 'unfollow:company:button:clicked'

    modelEvents:
      'change:followers_count' : 'render'

    # TODO:
    initialize: ->
      relationship = App.request "new:relationship:entity", @model
      @model.set relationship: relationship

  class Show.FollowRecommendations extends App.Views.CompositeView
    template: 'company/show/_follow_recommendations'
    childView: Show.FollowRecommendation
    childViewContainer: '.bb-company-recommendations'
    tagName: 'ul'
    className: 'list-group list-well recommendations_2'

  class Show.PriceTracker extends App.Views.ItemView
    template: 'company/show/_price_tracker'
    className: 'price-tracker-box'

  class Show.NavigationBarItem extends App.Views.ItemView
    template: 'company/show/_navigation_bar_item'
    className: 'list-group-item'

    triggers:
      'click': 'navigation:bar:item:clicked'

  class Show.NavigationBar extends App.Views.CompositeView
    template: 'company/show/_navigation_bar'
    childView: Show.NavigationBarItem
    childViewContainer: '.navigation-bar-items'
    className: 'list-group navigation-bar-box'

    onBeforeRender: ->
      _.each @collection.models, (model, index) ->
        model.set 'indexInCollection', index

  class Show.CompanyTrack extends App.Views.ItemView
    template: 'company/show/_company_track'

    modelEvents:
      'change:followers_count' : 'render'

    ui:
      followBtn: '.bb-follow-btn'
      unfollowBtn: '.bb-unfollow-btn'

    triggers:
      'click @ui.followBtn'   : 'follow:button:clicked'
      'click @ui.unfollowBtn' : 'unfollow:button:clicked'

  class Show.Company extends App.Views.Layout
    template: 'company/show/_company'
    className: 'panel panel-default sh-panel'

    regions:
      companyChartRegion: '.company-chart-region'
      companyTrackRegion: '.company-track-region'

    behaviors:
      LiveValues: {}

    bindings:
      '.bb-last-price':
        observe: 'quote.pricedata.last'
        update: ($el, val, model, options) ->
          @lastPriceAnimation model.previousAttributes().quote?.pricedata.last, val, @ui.lastPrice
        onGet: (value) ->
          @helpers.lastPriceFor(@model.get('quote'), { withChevron: false, commaSeparation: false })
      '.bb-change':
        observe: ['quote.pricedata.change', 'quote.pricedata.changepercent']
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.change
        onGet: (value) ->
          @helpers.stockChange(@model.get('quote'))
      '.bb-last-trade-time':
        observe: 'quote.pricedata.lasttradedatetime'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.lastTradeTime
        onGet: (value) ->
          @helpers.lastTradeTimeFor(@model.get('quote'))
      '.bb-prev-close':
        observe: 'quote.pricedata.prevclose'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.prevClose
        onGet: (value) ->
          @helpers.prevCloseFor(@model.get('quote'))
      '.bb-open':
        observe: 'quote.pricedata.open'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.open
        onGet: (value) ->
          @helpers.openFor(@model.get('quote'))
      '.bb-bid':
        observe: ['quote.pricedata.bid', 'quote.pricedata.bidsize']
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.bid
        onGet: (value) ->
          @helpers.bidFor(@model.get('quote'))
      '.bb-ask':
        observe: ['quote.pricedata.ask', 'quote.pricedata.asksize']
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.ask
        onGet: (value) ->
          @helpers.askFor(@model.get('quote'))
      '.bb-share-volume':
        observe: 'quote.pricedata.sharevolume'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.shareVolume
        onGet: (value) ->
          @helpers.shareVolumeFor(@model.get('quote'))
      '.bb-regular-range':
        observe: ['quote.pricedata.low', 'quote.pricedata.high']
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.regularRange
        onGet: (value) ->
          quote = @model.get('quote')
          @helpers.rangeIndicatorFor(quote, @helpers.lowFor, @helpers.highFor,
                                     @helpers.rangePercentage(quote), 'Range')
      '.bb-week52-range':
        observe: ['quote.fundamental.week52low.content', 'quote.fundamental.week52high.content']
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.week52Range
        onGet: (value) ->
          quote = @model.get('quote')
          @helpers.rangeIndicatorFor(quote, @helpers.week52lowFor, @helpers.week52highFor,
                                     @helpers.week52rangePercentage(quote), '52 Week')
      '.bb-marketcap':
        observe: 'quote.fundamental.marketcap'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.marketcap
        onGet: (value) ->
          @helpers.marketcapFor(@model.get('quote'))
      '.bb-peratio':
        observe: 'quote.fundamental.peratio'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.peratio
        onGet: (value) ->
          @helpers.peratioFor(@model.get('quote'))
      '.bb-pbratio':
        observe: 'quote.fundamental.pbratio'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.pbratio
        onGet: (value) ->
          @helpers.pbratioFor(@model.get('quote'))
      '.bb-eps':
        observe: 'quote.fundamental.eps'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.eps
        onGet: (value) ->
          @helpers.epsFor(@model.get('quote'))
      '.bb-divident':
        observe: 'quote.fundamental.divident'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.divident
        onGet: (value) ->
          @helpers.dividentFor(@model.get('quote'))

    ui:
      lastPrice: '.bb-last-price'
      change: '.bb-change'
      lastTradeTime: '.bb-last-trade-time'
      prevClose: '.bb-prev-close'
      open: '.bb-open'
      bid: '.bb-bid'
      ask: '.bb-ask'
      shareVolume: '.bb-share-volume'
      regularRange: '.bb-regular-range'
      week52Range: '.bb-week52-range'
      marketcap: '.bb-marketcap'
      peratio: '.bb-peratio'
      pbratio: '.bb-pbratio'
      eps: '.bb-eps'
      divident: '.bb-divident'

    currentPercentageForRange: (low, high, current) ->
      if high != null and low != null and current != null
        movingRange   = high - low
        distanceToTop = high - current
        Math.round(distanceToTop/movingRange * 100)
      else
        "n/a"

    # TODO:
    initialize: ->
      relationship = App.request "new:relationship:entity", @model
      @model.set relationship: relationship

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        logoPresent: =>
          if asset_path("squared-logos/#{@model.normalizedAbbr()}.png") then true else false
        logoPath: =>
          asset_path("squared-logos/#{@model.normalizedAbbr()}.png")

  class Show.BreakingNews extends App.Views.ItemView
    template: 'company/show/_breaking_news'
    id: 'breaking-news'
