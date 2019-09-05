@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Favorite extends App.Entities.Model
    url: ->
      if @isNew() then Routes.api_favorites_path() else Routes.api_favorite_path(@get('id'))

  API =
    addFavorite: (post_id) ->
      favorite = new Entities.Favorite
      favorite.save post_id: post_id

    destroyFavorite: (post_id) ->
      favorite = new Entities.Favorite
        id: post_id
      favorite.destroy()

  App.reqres.setHandler "add:favorite:entity", (post_id) ->
    API.addFavorite(post_id)

  App.reqres.setHandler "destroy:favorite:entity", (post_id) ->
    API.destroyFavorite(post_id)
