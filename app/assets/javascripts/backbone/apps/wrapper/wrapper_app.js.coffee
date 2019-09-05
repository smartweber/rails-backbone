@Omega.module "WrapperApp", (WrapperApp, App, Backbone, Marionette, $, _) ->
  @startWithParent = false

  API =
    show: (options) ->
      wrapperOptions = { region: App.topRegion }
      _.extend wrapperOptions, options
      @controller = new App.Components.Wrapper.Controller wrapperOptions
    triggerLayoutChange: ->
      @controller.triggerMethod('wrapper:layout:change:request')

  WrapperApp.on "start", (options) ->
    API.show(options)

  WrapperApp.on "wrapper:layout:change:request", ->
    API.triggerLayoutChange()
