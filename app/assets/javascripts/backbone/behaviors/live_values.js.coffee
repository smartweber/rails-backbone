@Omega.module "Behaviors", (Behaviors, App, Backbone, Marionette, $, _) ->

  class Behaviors.LiveValues extends Marionette.Behavior

    onRender: ->
      @view.stickit()

    initialize: ->
      @view.helpers = Marionette.View.prototype.templateHelpers()
      @view.regularDataUpdateAnimationFor = (val, uiElement) ->
        uiElement.stop().fadeOut ->
          uiElement.html(val).fadeIn()
      @view.lastPriceAnimation = (prevValue, val, uiElement) ->
        backgroundMutationColor = if Number(prevValue) > Number(val) then 'rgb(255, 60, 60)' else 'rgb(60, 255, 60)'
        uiElement.stop().animate(
          backgroundColor: backgroundMutationColor
        , 400, ->
          uiElement.html(val)
        ).animate
          backgroundColor: 'white'
