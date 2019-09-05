@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Like extends App.Entities.Model
    url: ->
      if @isNew() then Routes.api_likes_path() else Routes.api_like_path(@get('id'))
    paramRoot: 'like'

  API =
    newLike: (likeable) ->
      like = likeable.get('like')
      attributes = if like? and not like.isDestroyed?()
        like
      else
        likeable_id: likeable.get('id')
        likeable_type: likeable.constructor.name
      like = new Entities.Like attributes
      like

  App.reqres.setHandler "new:like:entity", (likeable) ->
    API.newLike(likeable)
