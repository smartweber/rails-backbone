@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Tag extends App.Entities.Model
    to_param: ->
      @get('word')

  class Entities.TagCollection extends App.Entities.Collection
    model: Entities.Tag
    url: -> Routes.api_channels_path()

  API =
    getTopHashtags: (limit = 5) ->
      hashtags = new Entities.TagCollection
      hashtags.fetch({data: { limit: limit }})
      hashtags

  App.reqres.setHandler 'get:top:hashtags', ->
    API.getTopHashtags()

  App.reqres.setHandler 'get:top:hashtag', ->
    API.getTopHashtags(1)
