@Omega.module "CommandApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: 'command/show/layout'

    regions:
      leftColumnRegion: '.left-column-region'
      middleContainerRegion: '.middle-container-region'
      rightColumnRegion: '.right-column-region'

  class Show.LeftColumnLayout extends App.Views.Layout
    template: 'command/show/_left_column_layout'
    className: 'col-lg-5 col-md-6'

    regions:
      profileRegion: '.profile-region'
      trendingStocksRegion: '.trending-stocks-region'
      trendingChannelsRegion: '.trending-channels-region'

    ui:
      sectionLink: '.section-link'

    events:
      'click @ui.sectionLink' : 'onSectionLinkClicked'

    onSectionLinkClicked: (e) ->
      @trigger 'section:link:clicked', e

  class Show.TrendingChannel extends App.Views.ItemView
    template: 'command/show/_trending_channel'
    tagName: 'li'
    className: 'list-group-item'

    ui:
      channelLink: '.bb-channel-link'

    triggers:
      'click @ui.channelLink' : 'channel:link:clicked'

  class Show.TrendingChannels extends App.Views.CompositeView
    template: 'command/show/_trending_channels'
    tagName: 'ul'
    className: 'list-group list-well list-channels'
    childView: Show.TrendingChannel
    childViewContainer: '.bb-trending-channels'

  class Show.MiddleContainerLayout extends App.Views.Layout
    template: 'command/show/_middle_container_layout'
    className: 'col-lg-14 col-md-12'

    regions:
      breakingNewsRegion: '.breaking-news-region'
      commandTabsRegion: '.command-tabs-region'
      newPostFormRegion: '.new-post-region'
      feedRegion: '.feed-region'

  class Show.CommandTabsWidget extends App.Views.Layout
    template: 'command/show/_command_tabs_widget'
    className: 'well'

    regions:
      newsRegion: '.news-region'
      radarRegion: '.radar-region'
      marketMoversRegion: '.market-movers-region'
      mostVolumeRegion: '.most-volume-region'

  class Show.RadarListItem extends App.Views.ItemView
    template: 'command/show/_radar_list_item'
    tagName: 'tr'
    className: 'trade up'

    behaviors:
      LiveValues: {}

    ui:
      lastPrice: '.bb-last-price'
      change: '.bb-change'
      changePercent: '.bb-change-percent'

    bindings:
      '.bb-last-price':
        observe: 'quote.pricedata.last'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.lastPrice
          if @model.previousAttributes().quote?.pricedata.last < val
            @$el.removeClass('down').addClass('up')
          else
            @$el.removeClass('up').addClass('down')
        onGet: (value) ->
          Math.round10(@helpers.lastPrice(@model.get('quote')), -2)
      '.bb-change':
        observe: 'quote.pricedata.change'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.change
        onGet: (value) ->
          Math.round10(value, -2)
      '.bb-change-percent':
        observe: 'quote.pricedata.changepercent'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.changePercent
        onGet: (value) ->
          Math.round10(value, -2)

  class Show.RadarList extends App.Views.CollectionView
    childView: Show.RadarListItem
    tagName: 'table'
    className: 'table table-striped table-hover'

  class Show.Radar extends App.Views.Layout
    getTemplate: ->
      if @collection.length > 0
        'command/show/_radar'
      else
        'command/show/_empty_radar'

    regions:
      companiesListRegion: '.companies-list-region'

    triggers:
      'click .carousel-inner a' : 'company:chart:clicked'

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

  class Show.MarketMovers extends App.Views.ItemView
    template: 'command/show/_market_movers'

  class Show.MostVolume extends App.Views.ItemView
    template: 'command/show/_most_volume'

  class Show.NewPostForm extends App.Shared.Views.NewPostForm

  class Show.RightColumnLayout extends App.Views.Layout
    template: 'command/show/_right_column_layout'
    className: 'col-lg-5 col-md-6'

    regions:
      marketSnapshotsRegion: '.market-snapshots-region'
      marketHeadlinesRegion: '.market-headlines-region'
      followRecommendationRegion: '.follow-recommendation-region'
