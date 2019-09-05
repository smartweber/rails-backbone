@Omega.module "Behaviors", (Behaviors, App, Backbone, Marionette, $, _) ->

  class Behaviors.Scrollable extends Marionette.Behavior
    onAttach: ->
      $(@options.selector).enscroll
        showOnHover: true
        verticalTrackClass: 'track3'
        verticalHandleClass: 'handle3'
        addPaddingToPane: false
