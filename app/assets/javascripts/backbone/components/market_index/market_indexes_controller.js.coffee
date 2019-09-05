@Omega.module "Components.MarketIndex", (MarketIndex, App, Backbone, Marionette, $, _) ->

  class MarketIndex.Controller extends App.Controllers.Base

    initialize: (options) ->
      _.extend @, App.Extensions.LiveUpdates

      marketSnapshots = App.request "get:market_snapshot:company:entities"
      @region = options.region

      @showLoadingView()

      App.execute "when:fetched", marketSnapshots, =>
        @marketIndexesView = @getMarkedIndexView marketSnapshots
        @listenTo @layout, 'destroy', =>
          @unsubscribeFromLiveUpdates()

        @listenTo @marketIndexesView, 'childview:company:link:clicked', (child, args) ->
          App.navigate Routes.company_path(child.model), trigger: true

        @listenTo @region, 'show', =>
          @subscribeToLiveUpdates marketSnapshots.models

        @region.show @marketIndexesView
      , =>
        @showEmptyView()


    getMarkedIndexView: (marketSnapshots) ->
      new MarketIndex.CompositeIndexes
        collection: marketSnapshots

    showLoadingView: ->
      loadingView = @getLoadingView()
      @region.show loadingView

    getLoadingView: ->
      new MarketIndex.Loading

    showEmptyView: ->
      emptyView = @getEmptyView()
      @region.show emptyView

    getEmptyView: ->
      new MarkeIndex.Empty


  App.reqres.setHandler "components:market_index", (region) ->
    new MarketIndex.Controller
      region: region
