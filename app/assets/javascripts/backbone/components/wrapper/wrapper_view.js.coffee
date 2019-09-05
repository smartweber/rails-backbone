@Omega.module "Components.Wrapper", (Wrapper, App, Backbone, Marionette, $, _) ->

  class Wrapper.Layout extends App.Views.Layout
    getTemplate: ->
      if @options.layout
        "wrapper/#{@options.layout}_layout"
      else
        "wrapper/home_layout"

    regions: (options) ->
      defaultRegions =
        headerRegion: '#header-region'
        mainRegion: '#main-region'

