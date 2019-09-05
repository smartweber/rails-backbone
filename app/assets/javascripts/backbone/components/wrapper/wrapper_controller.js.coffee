@Omega.module "Components.Wrapper", (Wrapper, App, Backbone, Marionette, $, _) ->

  class Wrapper.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options) ->
      currentPath = Backbone.history.fragment
      @loginPath  = new RegExp(s(Routes.new_user_session_path()).ltrim('/').value())
      @specialLayouts = ['login', 'password', 'signup', 'users', 'messages', 'c', 'settings']
      @layoutType = @getLayoutType currentPath
      @layout     = @getLayoutView()

      @listenTo @, 'wrapper:layout:change:request', =>
        newPath = Backbone.history.fragment
        requestedLayoutType = @getLayoutType newPath
        if requestedLayoutType != @layoutType
          @layoutType = requestedLayoutType
          @layout     = @getLayoutView()
          @region.reset()
          if @layout.headerRegion
            @bindHeaderRegionListener()

          @show @layout

      App.reqres.setHandler "wrapper:main:region", =>
        @layout.mainRegion

      if @layout.headerRegion
        @bindHeaderRegionListener()

      @show @layout

    getLayoutView: ->
      new Wrapper.Layout
        layout: @layoutType

    getLayoutType: (path) ->
      path = s(path).words('/')[0]
      # undefined path means root url
      if(path && _.contains(@specialLayouts, path)) or path == undefined then path else 'default'

    bindHeaderRegionListener: ->
      App.reqres.setHandler "wrapper:header:region", =>
        @layout.headerRegion
