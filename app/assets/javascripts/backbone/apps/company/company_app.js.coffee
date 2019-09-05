@Omega.module "CompanyApp", (CompanyApp, App, Backbone, Marionette, $, _) ->

  class CompanyApp.Router extends App.Routers.Base
    appRoutes:
      "c/:abbr(/)" : "show"

  API =
    show: (abbr) ->
      new CompanyApp.Show.Controller
        abbr: abbr

  App.addInitializer ->
    new CompanyApp.Router
      controller: API
