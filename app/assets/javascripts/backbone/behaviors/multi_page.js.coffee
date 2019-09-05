 @Omega.module "Behaviors", (Behaviors, App, Backbone, Marionette, $, _) ->

  class Behaviors.MultiPage extends Marionette.Behavior
    defaults:
      'batchSize': 4

    initialize: ->
      @initAdditionalRegions()

    initAdditionalRegions: ->
      lists = _.groupBy(@view.options.collection.models, (element, index) =>
        Math.floor index / @options.batchSize
      )
      @view.groupedCollection = _.toArray(lists)
      range = _.range(@view.groupedCollection.length)
      @view.pageRegionsNames = _.map range, (num) ->
        'pageRegion' + num
      @view.pageRegionsSelectors = _.map range, (num) ->
        '.page-region-' + num
      @view.addRegions _.object(@view.pageRegionsNames, @view.pageRegionsSelectors)
      @view.trigger('regionsAllocated')
