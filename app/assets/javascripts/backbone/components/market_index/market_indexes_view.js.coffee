@Omega.module "Components.MarketIndex", (MarketIndex, App, Backbone, Marionette, $, _) ->

  class MarketIndex.CompositeIndex extends App.Views.ItemView
    template: 'market_index/_composite_index'

    triggers:
      'click a' : 'company:link:clicked'

    behaviors:
      LiveValues: {}

    ui:
      essentialData: '.bb-essential-data'

    bindings:
      '.bb-essential-data':
        observe: ['quote.pricedata.last', 'quote.pricedata.change', 'quote.pricedata.changepercent']
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.essentialData
        onGet: (value) ->
          @helpers.essentialDataFor(@model.get('quote'), { coefficient: @getCoefficient() })

# TODO: refactor
    getCoefficient: ->
      @model.specialMapping[@model.get('abbr')].coefficient

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        simplifiedName: =>
          @model.specialMapping[@model.get('abbr')].simpleName

  class MarketIndex.CompositeIndexes extends App.Views.CompositeView
    template: 'market_index/_composite_indexes'
    childView: MarketIndex.CompositeIndex
    childViewContainer: '.bb-composite-indexes'

  class MarketIndex.Loading extends App.Views.ItemView
    # TODO: We need to put the correct template here for loading design
    template: 'market_index/_composite_indexes'
    className: 'loading-market-indexes'

  class MarketIndex.Empty extends App.Views.ItemView
    # TODO: We need to put the correct template here for Empty state view.
    template: 'market_index/_composite_indexes'
    className: 'no-marker-indexes'
