@Omega.module "Components.BreakingNews", (BreakingNews, App, Backbone, Marionette, $, _) ->

  class BreakingNews.Item extends App.Views.ItemView
    template: 'breaking_news/_breaking_news'
    className: 'box-breaking-news'
