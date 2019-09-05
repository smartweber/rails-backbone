@Omega.module "Components.NewsCarousel", (NewsCarousel, App, Backbone, Marionette, $, _) ->

  class NewsCarousel.NewsItem extends App.Views.ItemView
    getTemplate: ->
      "news_carousel/_carousel_news_item"
    className: 'item'

    triggers:
      'click' : 'carousel:news:item:clicked'

    events:
      'mouseenter' : 'setActive'

    setActive: ->
      @model.collection.activeModelId = @model.get('id')

  class NewsCarousel.News extends App.Views.CollectionView
    childView: NewsCarousel.NewsItem
    className: 'bb-carousel-news'

  class NewsCarousel.Loading extends App.Views.ItemView
    template: 'news_carousel/_carousel_loading'
    className: 'no-companies-radar-banner'

  class NewsCarousel.Layout extends App.Views.Layout
    getTemplate: ->
      "news_carousel/_carousel_layout"
    id: 'tab1'
    className: 'tab-pane'
    attributes:
      role: 'tabpanel'

    behaviors:
      MultiPage:
        batchSize: 4

    childEvents:
      'childview:carousel:news:item:clicked': (carouselNews, child) ->
        @trigger 'region:carousel:news:item:clicked', child

    ui:
      activeNewsStory: '.bb-news-active'

    triggers:
      'click @ui.activeNewsStory' : 'carousel:active:news:item:clicked'

    firstItem: ->
      if @groupedCollection.length > 0 then @groupedCollection[0][0] else undefined

    # TODO: move that to MultiPage somehow
    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        pageRegionsSelectors: @pageRegionsSelectors
        groupedCollection: @groupedCollection
        firstItem: =>
          @firstItem()
