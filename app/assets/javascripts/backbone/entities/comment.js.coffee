@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Comment extends App.Entities.Model
    urlRoot: -> Routes.api_comments_path()
    paramRoot: 'comment'

    initialize: ->
      _.extend @, App.Extensions.Likeable

  class Entities.CommentCollection extends App.Entities.Collection
    model: Entities.Comment

    url: ->
      Routes.api_comments_path()

  API =
    getComments: (commentable_id, commentable_type) ->
      comments = new Entities.CommentCollection
      comments.fetch({data: {commentable_type: commentable_type, commentable_id: commentable_id}})
      comments

    newCommentCollection: (models) ->
      comments = new Entities.CommentCollection models
      comments

    newCommentFor: (commentable, replyTarget) ->
      reply_to_comment_id = replyTarget.model.id if replyTarget.constructor.name == 'Comment'

      attributes =
        reply_to_comment_id: reply_to_comment_id
        commentable_id: commentable.get('id')
        commentable_type: 'Post'

      @newComment attributes

    newComment: (attributes) ->
      comment = new Entities.Comment attributes
      comment

  App.reqres.setHandler "comment:entities", (commentable_id, commentable_type) ->
    API.getComments commentable_id, commentable_type

  App.reqres.setHandler "new:comment:entities", (models) ->
    API.newCommentCollection models

  App.reqres.setHandler "new:comment:entity:for", (commentable, replyTarget) ->
    API.newCommentFor commentable, replyTarget

  App.reqres.setHandler "new:comment:entity:from:attributes", (attributes) ->
    API.newComment attributes

