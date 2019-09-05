@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Article extends App.Entities.Model
    url: -> Routes.api_article_path(@get('slug'))
    paramRoot: 'news_article'
    idAttribute: "slug"

  class Entities.ArticleCollection extends App.Entities.Collection
    model: Entities.Article
    url: -> Routes.api_articles_path()

  API =
    getArticle: (slug) ->
      article = new Entities.Article slug: slug
      article.fetch()
      article

    getTopArticles: ->
      articles = new Entities.ArticleCollection
      articles.fetch()
      articles

  App.reqres.setHandler 'get:article:entity', (slug) ->
    API.getArticle(slug)

  App.reqres.setHandler 'get:top:article:entities', ->
    API.getTopArticles()
