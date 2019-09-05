@Omega.module "Behaviors", (Behaviors, App, Backbone, Marionette, $, _) ->

  class Behaviors.Attachable extends Marionette.Behavior
    defaults:
      multipartForm: true

    events:
      'click .bb-attach-link' : 'onAttachedLinkClick'

    initialize: ->
      @listenTo @view, 'show', =>
        @attachmentsRegion()

    attachmentsRegion: ->
      collection      = App.request "new:attachment:entities"
      attachmentsView = @getAttachmentsView collection
      @view.attachmentsRegion.show attachmentsView

    getAttachmentsView: (collection) ->
      attachmentsView = new App.Shared.Views.NewAttachments
        collection: collection
      attachmentsView

    onAttachedLinkClick: ->
      attachment = App.request "new:attachment:entity", { attachable_type: @getOption('attachableType'), type_of_attachment: 'image' }
      attachment.multipartForm = @getOption('multipartForm')
      @view.attachmentsRegion.currentView.collection.push attachment
      _.last(_.values(@view.attachmentsRegion.currentView.children._views)).ui.hiddenFileInput.click()
