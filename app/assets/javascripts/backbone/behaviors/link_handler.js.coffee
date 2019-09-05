@Omega.module "Behaviors", (Behaviors, App, Backbone, Marionette, $, _) ->

  class Behaviors.LinkHandler extends Marionette.Behavior
    events:
      'click a' : 'onPostLinkClicked'

    onPostLinkClicked: (e) ->
      @view.trigger 'post:tag:clicked', e
