@Omega.module "Behaviors", (Behaviors, App, Backbone, Marionette, $, _) ->

  class Behaviors.Pasteable extends Marionette.Behavior
    initialize: ->
      @listenTo @view, @getOption('eventName'), (args) ->
        urlRegex  = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
        setTimeout (=>
          text    = @view.$el.find('textarea').val()
          results = text.match(urlRegex)
          unless _.isEmpty(results)
            @view.attachmentsRegion.currentView.collection.create {
              link: results[0]
              attachable_type: @getOption('attachableType')
              }, { wait: true }
        ), 0
