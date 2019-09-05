# Relationship is the form of connection(following) between two users and has two directions
#
#   Example: when user1 follows user2, relationship record created with the following attributes:
#     { .., follower_id: user1.id, followable_id: user2.id }

@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Relationship extends App.Entities.Model
    url: ->
      if @isNew() then Routes.api_relationships_path() else Routes.api_relationship_path(@get('id'))

  API =
    createRelationship: (followable) ->
      relationship = new Entities.Relationship followable_id: followable.id, followable_type: followable.type
      relationship.url = Routes.api_relationships_path
      relationship.save()
      relationship

    newRelationship: (followable) ->
      relationship = if (followable instanceof Backbone.Model)
        followable.get('relationship')
      else
        followable.relationship
      attributes = if relationship? and not relationship.isDestroyed?()
        relationship
      else
        followable_id: followable.get('id')
        followable_type: followable.constructor.name
      relationship = new Entities.Relationship attributes
      relationship

  App.reqres.setHandler "create:relationship:entity", (followable) ->
    API.createRelationship followable

  App.reqres.setHandler "new:relationship:entity", (followable) ->
    API.newRelationship followable
