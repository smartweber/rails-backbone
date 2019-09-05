@Omega.module "Routers", (Routers, App, Backbone, Marionette, $, _) ->

  class Routers.Base extends Marionette.AppRouter

    execute: (callback, args) ->
      if App.WrapperApp._isInitialized
        App.WrapperApp.trigger('wrapper:layout:change:request')
      else
        App.module('WrapperApp').start
          path: Backbone.history.fragment
      headerRegion = App.request "wrapper:header:region"

      if headerRegion
        App.module("HeaderApp").stop()
        App.module("HeaderApp").start()
      if callback
        callback.apply @, args

    before:
      '*any': 'checkAuthorization'

    checkAuthorization: (fragment, args, next) ->
      hasAccess = App.currentUser.hasAccessTo(fragment, args)
      unless hasAccess
        App.navigate '/login', trigger: true
      else
        next()
