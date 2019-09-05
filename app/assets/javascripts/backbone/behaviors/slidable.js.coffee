@Omega.module "Behaviors", (Behaviors, App, Backbone, Marionette, $, _) ->

  class Behaviors.Slidable extends Marionette.Behavior
    events:
      'click @ui.slidableElement' : 'onSlideDownElementClicked'
      'focusout @ui.slidableElement' : 'onSlideDownElementFocusOut'

    onSlideDownElementClicked: ->
      $(@ui.slidableElement).animate { height: '100px' }, 'medium'
      $(@ui.slidableElement).parents('.panel').find('.panel-footer').slideDown 'medium'

    onSlideDownElementFocusOut: (e) ->
      setTimeout (=>
        $(@ui.slidableElement).animate { height: '37px' }, 'medium'
      ), 100