@Omega.module "Components.TrendingStock", (TrendingStock, App, Backbone, Marionette, $, _) ->

  class TrendingStock.Controller extends App.Controllers.Base

    initialize: (options) ->
      _.extend @, App.Extensions.LiveUpdates

      trendingStocks = App.request 'get:trending_stocks:company:entities'
      @region = options.region

      @showLoadingView()

      App.execute 'when:fetched', trendingStocks, =>
        @trendingStocksLayoutView = @getTrendingStocksLayoutView trendingStocks
        @listenTo @trendingStocksLayoutView, 'region:company:chart:clicked', (child, args) ->
          App.navigate Routes.company_path(child.model), trigger: true
        @listenTo @trendingStocksLayoutView, 'show', =>
          _.each @trendingStocksLayoutView.groupedCollection, (companies, index) =>
            tilesCollectionView = @getTilesCollectionView(new App.Entities.CompanyCollection companies)
            @listenTo tilesCollectionView, 'childview:hover:company:tile:triggered', (child, args) =>
              @trendingStocksLayoutView.companyChartRegion.show @getChartView( child.model )
            @trendingStocksLayoutView.getRegion( @trendingStocksLayoutView.pageRegionsNames[index] ).show tilesCollectionView
          chartView = @getChartView( trendingStocks.models[0] )
          @trendingStocksLayoutView.companyChartRegion.show chartView

        @subscribeToLiveUpdates( trendingStocks.models )

        @region.show @trendingStocksLayoutView
      , =>
        @showEmptyView()

    showLoadingView: ->
      loadingView = @getLoadingView()
      @region.show loadingView

    getLoadingView: ->
      new TrendingStock.Loading

    getTrendingStocksLayoutView: (trendingStocks) ->
      new TrendingStock.TrendingStocksLayout
        collection: trendingStocks

    getTilesCollectionView: (companies) ->
      new App.Shared.Views.Tiles
        collection: companies

    getChartView: (company) ->
      new App.Shared.Views.CompanyChart
        model: company

    showEmptyView: ->
      emptyView = @getEmptyView()
      @region.show emptyView

    getEmptyView: ->
      new TrendingStock.Empty

  App.reqres.setHandler "components:trending_stock", (region, trendingStocks) ->
    new TrendingStock.Controller
      region: region
      trendingStocks: trendingStocks
