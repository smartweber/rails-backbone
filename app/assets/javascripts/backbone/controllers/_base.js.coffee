@Omega.module "Controllers", (Controllers, App, Backbone, Marionette, $, _) ->

  class Controllers.Base extends Marionette.Controller

    constructor: (options = {}) ->
      @region = options.region or App.request "wrapper:main:region"
      super options
      @setPageTitle() unless @disableTitleAutoSetting
      @_instance_id = _.uniqueId("controller")
      App.execute "register:instance", @, @_instance_id

    destroy: (args...) ->
      delete @region
      delete @options
      super args
      App.execute "unregister:instance", @, @_instance_id

    show: (view) ->
      @listenTo view, "close", @close
      @region.show view

    setPageTitle: ->
      App.execute "set:page:title", @pageTitle()

    refreshPageTitle: ->
      @setPageTitle()

    pageTitle: ->
      "Stockharp - Financial Platform, Stock Market, Business News"
