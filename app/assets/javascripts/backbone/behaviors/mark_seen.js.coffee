@Omega.module "Behaviors", (Behaviors, App, Backbone, Marionette, $, _) ->

  class Behaviors.MarkSeen extends Marionette.Behavior

    events:
      'click .bb-seenable, a' : 'onNotificationLinkClicked'

    onNotificationLinkClicked: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @view.trigger 'notification:link:clicked', e
