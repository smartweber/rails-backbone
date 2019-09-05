@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Post extends App.Entities.Model
    validation:
      content:
        required: true
        maxLength: 140
        maxCashtags: 3
        pageSpecificCashtagRequired: true

    initialize: ->
      _.extend @, App.Extensions.Likeable
      comments = App.request "new:comment:entities", @get('comments')
      @listenTo comments, 'add remove reset', (model, collection) =>
        @set comments_count: collection.length
      attachments = App.request "new:attachment:entities", @get('attachments')
      @set comments: comments, attachments: attachments

    urlRoot: -> Routes.api_posts_path()

    addToFavorites: ->
      App.request "add:favorite:entity", @id
      @set favorited: true

    removeFromFavorites: ->
      App.request "destroy:favorite:entity", @id
      @set favorited: false

  class Entities.PostCollection extends App.Entities.Collection
    model: Entities.Post
    url: -> Routes.api_favorites_path()

    parse: (response) ->
      response.posts

  API =
    newPost: (attributes) ->
      post = new Entities.Post attributes
      post

  App.reqres.setHandler "new:post:entity", (attributes) ->
    API.newPost attributes
