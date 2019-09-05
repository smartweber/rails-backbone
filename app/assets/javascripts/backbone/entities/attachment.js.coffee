@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Attachment extends App.Entities.Model
    urlRoot: -> Routes.api_user_attachments_path()

    isLink: ->
      @get('type_of_attachment') == 'link'

    isImage: ->
      @get('type_of_attachment') == 'image'

  class Entities.AttachmentCollection extends App.Entities.Collection
    model: Entities.Attachment

  API =
    newAttachmentCollection: (attachments) ->
      attachments = new Entities.AttachmentCollection attachments
      attachments

    newAttachment: (attributes) ->
      attachment = new Entities.Attachment attributes
      attachment

  App.reqres.setHandler "new:attachment:entities", (attachments) ->
    API.newAttachmentCollection attachments

  App.reqres.setHandler "new:attachment:entity", (attributes) ->
    API.newAttachment attributes
