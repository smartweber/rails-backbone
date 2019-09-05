@Omega.module "ArticleApp", (ArticleApp, App, Backbone, Marionette, $, _) ->

  class ArticleApp.Router extends App.Routers.Base
    appRoutes:
      "articles/:id(/)" : "showArticle"
      "news-articles/:id(/)" : "showNewsArticle"

  API =
    showArticle: (id) ->
      new ArticleApp.Show.Controller
        id: id
        entityRequestCommand: "get:article:entity"

    showNewsArticle: (id) ->
      new ArticleApp.Show.Controller
        id: id
        entityRequestCommand: "get:general_news_item:entity"

  App.addInitializer ->
    new ArticleApp.Router
      controller: API
