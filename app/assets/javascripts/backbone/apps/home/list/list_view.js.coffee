@Omega.module "HomeApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Layout extends App.Views.Layout
    template: 'home/list/layout'

    regions:
      leftColumnRegion: '.left-column-region'
      rightColumnRegion:  '.right-column-region'
      featuresRegion: '.features-region'
      signupFooterLinksRegion: '.signup-footer-links-region'

  class List.LeftColumnLayout extends App.Views.Layout
    template: 'home/list/_left_column_layout'
    className: 'col-md-15'

    regions:
      marketIndexesRegion: '.market-indexes-region'
      carouselNewsRegion: '.carousel-news-region'
      breakingNewsRegion: '.breaking-news-region'
      # trendingChannelRegion: '.trending-channel-region'
      trendingStocksRegion: '.trending-stocks-region'
      marketHeadlinesRegion: '.market-headlines-region'

  class List.RightColumnLayout extends App.Views.Layout
    template: 'home/list/_right_column_layout'
    className: 'col-md-9'

    regions:
      # compositeIndexesRegion: '.composite-indexes-region'
      newsRegion: '.news-region'
      trendingStreamRegion: '.trending-stream-region'

  class List.NewsItem extends App.Views.ItemView
    template: 'home/list/_news_item'
    tagName: 'li'

    triggers:
      'mouseover': 'mouseover:news_item'
      'click': 'news_item:clicked'

  class List.News extends App.Views.CompositeView
    template: 'home/list/_news'
    childView: List.NewsItem
    childViewContainer: '.bb-news-items'
    className: 'panel panel-default panel-sh panel-stories'

    childEvents:
      'news_item:clicked': (childview) ->
        @trigger 'region:news_item:clicked', childview

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        firstItem: => _.first(@collection.models)

    onBeforeRender: ->
      _.each @collection.models, (model, index) ->
        model.set 'indexInCollection', index + 1

  class List.TrendingChannelItem extends App.Views.ItemView
    template: 'home/list/_trending_channel_item'
    tagName: 'li'

    behaviors:
      LinkHandler: {}

  class List.TrendingChannel extends App.Views.CompositeView
    template: 'home/list/_trending_channel'
    childView: List.TrendingChannelItem
    childViewContainer: '.bb-trending-channel-items'
    className: 'panel panel-default panel-main'

    childEvents:
      'post:tag:clicked': (childview, e) ->
        e.preventDefault()
        e.stopPropagation()
        @trigger 'region:post:tag:clicked', e

  class List.TrendingStocksLayout extends App.Views.Layout
    template: 'home/list/_trending_stocks_layout'
    className: 'panel panel-default panel-sh panel-trending-stock'

    regions:
      companiesListRegion: '.companies-list-region'
      companyChartRegion: '.company-chart-region'

    childEvents:
      'company:chart:clicked' : (args) ->
        @triggerMethod 'region:company:chart:clicked', args

    behaviors:
      MultiPage:
        batchSize: 10

    # TODO: move that to MultiPage somehow
    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        pageRegionsSelectors: @pageRegionsSelectors
        groupedCollection: @groupedCollection

  class List.MarketHeadline extends App.Views.ItemView
    template: 'home/list/_market_headline'
    tagName: 'li'

  class List.MarketHeadlines extends App.Views.CompositeView
    template: 'home/list/_market_headlines'
    childView: List.MarketHeadline
    childViewContainer: '.bb-items'
    className: 'market-headlines'

  class List.SignupFooterLinks extends App.Views.ItemView
    template: 'home/list/_signup_footer_links'
    className: 'container'

    ui:
      loginBtn: '.bb-login-btn'
      signupBtn: '.bb-signup-btn'

    triggers:
      'click @ui.loginBtn': 'login:button:clicked'
      'click @ui.signupBtn': 'signup:button:clicked'
