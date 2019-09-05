@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Participant extends App.Entities.Model
    url: ->
      Routes.api_participant_path(@id)
    paramRoot: 'participant'

  class Entities.ParticipantCollection extends App.Entities.Collection
    model: Entities.Participant
    # TODO: replace this hardcoded string
    url: ->
      '/participants'

  API =
    newParticipantCollection: (models) ->
      participants = new Entities.ParticipantCollection models
      participants

  App.reqres.setHandler "new:participant:entities", (models) ->
    API.newParticipantCollection models
