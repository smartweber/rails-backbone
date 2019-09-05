@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.MarketHeadline extends App.Entities.Model

  class Entities.MarketHeadlineCollection extends App.Entities.Collection
    model: Entities.MarketHeadline
    url: -> Routes.api_market_headlines_path()

  API =
    getTopMarketHeadlines: ->
      marketHeadlines = new Entities.MarketHeadlineCollection
      marketHeadlines.fetch()
      marketHeadlines

  App.reqres.setHandler "get:market_headline:entities", ->
    API.getTopMarketHeadlines()
