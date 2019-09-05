@Omega.module "Components.BreakingNews", (BreakingNews, App, Backbone, Marionette, $, _) ->

  class BreakingNews.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options) ->
      breakingNews = App.request 'get:breaking_news:entity'
      @region = options.region

      App.vent.on "update:breaking_news:received", (attributes) =>
        @breakingNewsRegion attributes

      App.execute "when:fetched", breakingNews, =>
        @breakingNewsRegion breakingNews

    breakingNewsRegion: (modelOrObj) ->
      model = unless modelOrObj instanceof Backbone.Model
         App.request "new:breaking_news:entity", modelOrObj
      else
        modelOrObj
      if model.get('deleted') and model.get('id') == @region.currentView.model.get('id')
        @region.reset()
      else unless model.isNew()
        @componentView = @getBreakingNewsView model
        @region.show @componentView

    getBreakingNewsView: (breakingNews) ->
      new BreakingNews.Item
        model: breakingNews


  App.commands.setHandler "render:components:breaking_news", (options) ->
    throw new Error "You should provide a region" unless options.region
    new BreakingNews.Controller
      region: options.region
