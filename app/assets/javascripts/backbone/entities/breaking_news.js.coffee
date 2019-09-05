@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.BreakingNews extends App.Entities.Model
    urlRoot: -> Routes.api_breaking_news_path()

  API =
    getBreakingNews: ->
      breaking_news = new Entities.BreakingNews
      breaking_news.fetch()
      breaking_news

    newBreakingNews: (attributes) ->
      new Entities.BreakingNews attributes

  App.reqres.setHandler "get:breaking_news:entity", ->
    API.getBreakingNews()

  App.reqres.setHandler "new:breaking_news:entity", (attributes) ->
    API.newBreakingNews attributes
