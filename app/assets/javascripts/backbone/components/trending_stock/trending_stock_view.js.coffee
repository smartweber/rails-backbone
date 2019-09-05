@Omega.module "Components.TrendingStock", (TrendingStock, App, Backbone, Marionette, $, _) ->

  class TrendingStock.TrendingStocksLayout extends App.Views.Layout
    template: 'trending_stock/_trending_stocks_layout'
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

  class TrendingStock.Loading extends App.Views.ItemView
    # TODO: we should be using a loading template here.
    template: 'trending_stock/_trending_stocks_layout'
    className: 'loading-trending-stock'

  class TrendingStock.Empty extends App.Views.ItemView
    # TODO: we should be using a loading template here.
    template: 'trending_stock/_trending_stocks_layout'
    className: 'no-trending-stock'
