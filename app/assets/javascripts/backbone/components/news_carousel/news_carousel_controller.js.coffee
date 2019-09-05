@Omega.module "Components.NewsCarousel", (NewsCarousel, App, Backbone, Marionette, $, _) ->

  class NewsCarousel.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options) ->
      @promises = []
      carouselNews = App.request 'get:carousel_news:entities'
      @region = options.region

      @showLoadingView()

      App.execute "when:fetched", carouselNews, =>
        @contentView = @getNewsLayout carouselNews

        @listenTo @contentView, 'show', =>
          @newsRegion carouselNews

        @region.show @contentView

    showLoadingView: ->
      loadingView = @getLoadingView()
      @region.show loadingView

    newsRegion: (carouselNews) ->
      _.each @contentView.groupedCollection, (news, index) =>
        newsArticles = App.request 'new:news:entities', news
        newsCollectionView = @getNewsCollectionView newsArticles
        @contentView.getRegion(@contentView.pageRegionsNames[index]).show newsCollectionView
      @executeExtraFunctions()
      @listenTo @contentView, 'region:carousel:news:item:clicked', (child) ->
        window.open(child.model.get('url'), '_blank')
      @listenTo @contentView, 'carousel:active:news:item:clicked', (args) ->
        activeItem = args.collection.get(args.collection.activeModelId) || args.view.firstItem()
        window.open(activeItem.get('url'), '_blank')

    getNewsLayout: (carouselNews) ->
      new NewsCarousel.Layout
        collection: carouselNews

    getLoadingView: ->
      new NewsCarousel.Loading

    getNewsCollectionView: (news) ->
      new NewsCarousel.News
        collection: news

    # TODO:
    executeExtraFunctions: ->
      # Swipe for bootstrap carousels
      $('.carousel').swiperight ->
        $(this).carousel 'prev'
        return
      $('.carousel').swipeleft ->
        $(this).carousel 'next'
        return
      $('.item').hover (->
        selctimg = $(this).find('img').data('bigger-image-src')
        $('#news-active').find('img').attr 'src', selctimg
        newMainTitle = $(this).find('.item-title').html()
        newMainSummary = $(this).find('.item-text').html()
        $('#news-active').find('.news-item-title').html newMainTitle
        $('#news-active').find('.news-item-text').html newMainSummary
        return
      ), ->

      # Silver Track carousel for news tab
      jQuery.fn.extend
        loadSilverTrack: ->
          example = $(this)
          parent = example.parents('.track')
          track = example.silverTrack(animationAxis: "y" ,mode: 'vertical')
          track.install new (SilverTrack.Plugins.Css3Animation)
          track.install new (SilverTrack.Plugins.Navigator)(
            prev: $('a.prev', parent)
            next: $('a.next', parent))
          track.install new (SilverTrack.Plugins.CircularNavigator)(autoPlay: false)
          track.install new (SilverTrack.Plugins.ResponsiveHubConnector)(
            layouts: [
              'phone'
              'tablet'
              'small-desktop'
              'large-desktop'
            ]
            onReady: (track, options, event) ->
              options.onChange track, options, event
              return
            onChange: (track, options, event) ->
              track.options.mode = 'vertical'
              track.options.perPage = 3
              track.options.autoHeight = true
              track.restart keepCurrentPage: true
              return
          )
          track.start()

          $.responsiveHub 'change', 'phone', (event) ->
            alert event.layout
            return

          $.responsiveHub
            layouts:
              768: 'phone'
              992: 'tablet'
              1200: 'small-desktop'
              1400: 'large-desktop'
            defaultLayout: 'large-desktop'
          return

      $('.news').bind 'click', ->
        setTimeout (->
          $('#news-carousel').loadSilverTrack()
          return
        ), 100
        return
      $(window).resize ->
        $('#news-carousel').loadSilverTrack()
      $('#news-carousel').loadSilverTrack()

  App.reqres.setHandler "components:carousel", (region) ->
    new NewsCarousel.Controller
      region: region
