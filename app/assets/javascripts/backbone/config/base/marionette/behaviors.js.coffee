do (Marionette) ->
  _.extend Marionette.Behaviors,

    getBehaviorClass: (options, className) ->
      @behaviorsLookup().module('Behaviors.'+className)
