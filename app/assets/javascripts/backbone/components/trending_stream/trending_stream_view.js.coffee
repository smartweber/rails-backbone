@Omega.module "Components.TrendingStream", (TrendingStream, App, Backbone, Marionette, $, _) ->

  class TrendingStream.TrendingStreamItem extends App.Views.ItemView
    template: 'trending_stream/_trending_stream_item'
    className: 'list-group-item'

    behaviors:
      LinkHandler: {}

  class TrendingStream.Stream extends App.Views.CompositeView
    template: 'trending_stream/_trending_stream'
    emptyView: TrendingStream.Empty
    childView: TrendingStream.TrendingStreamItem
    childViewContainer: '.bb-trending-stream-items'
    className: 'panel panel-default panel-sh panel-trending'

    childEvents:
      'post:tag:clicked': (childview, e) ->
        e.preventDefault()
        e.stopPropagation()
        @trigger 'region:post:tag:clicked', e

  class TrendingStream.Loading extends App.Views.ItemView
    template: 'trending_stream/_loading'
    className: 'loading-treding-stream'

  class TrendingStream.Empty extends App.Views.ItemView
    template: 'trending_stream/_empty'
    className: 'no-trending-stream'
