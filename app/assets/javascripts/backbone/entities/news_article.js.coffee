@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.NewsArticle extends App.Entities.Model
    urlRoot: -> Routes.api_news_articles_path()
    paramRoot: 'news_article'
    idAttribute: 'slug'

    initialize: ->
      @_get = _.bind App.Entities.Model.prototype.get, @

    get: (attr) ->
      if attr == "url"
        @getUrl()
      else
        @_get(attr)

    getUrl: ->
      if @get('locally_hosted') == true
        console.log @get('slug')
        Routes.news_article_path(@get('slug'))
      else
        @_get('url')

  class Entities.NewsArticleCollection extends App.Entities.Collection
    model: Entities.NewsArticle
    url: -> Routes.api_news_articles_path()
    page: 1

  API =
    getNewsArticlesByURL: (url, page = 1) ->
      collection = API.newNewsArticlesCollection()
      collection.url = url
      collection.fetch({data: {page: page}})
      collection

    getNewsArticle: (slug) ->
      newsArticle = new Entities.NewsArticle slug: slug
      newsArticle.fetch()
      newsArticle

    getNewsArticlesByPositionRange: (lowBorder, highBorder) ->
      collection = API.newNewsArticlesCollection()
      collection.url = Routes.ranged_api_news_articles_path()
      collection.fetch({data: {lowBorder: lowBorder, highBorder: highBorder}})
      collection

    getCompanyNews: (abbr, page) ->
      collection = API.newNewsArticlesCollection()
      collection.url = Routes.api_company_news_index_path(abbr)
      collection.fetch({data: {page: page}})
      collection

    newNewsArticlesCollection: (news=[]) ->
      new App.Entities.NewsArticleCollection news

  App.reqres.setHandler "get:news:articles", (page = 1) ->
    API.getNewsArticlesByURL Routes.api_news_articles_path(), page

  App.reqres.setHandler "get:general_news_item:entity", (slug) ->
    API.getNewsArticle(slug)

  App.reqres.setHandler "get:carousel_news:entities", ->
    API.getNewsArticlesByPositionRange 9, 17

  App.reqres.setHandler "get:landing_news:entities", ->
    API.getNewsArticlesByPositionRange 1, 8

  App.reqres.setHandler "get:company_news:entities", (abbr, page) ->
    API.getCompanyNews abbr, page

  App.reqres.setHandler "new:news:entities", (news) ->
    API.newNewsArticlesCollection news
