@Omega.module "ChatApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.MessageForm extends App.Shared.Views.Form
    template: 'chat/new/_message_form'
    modelClassName: 'Message'
    inputFields: ->
      ['body']

    regions:
      attachmentsRegion: '.attachments-region'

    ui:
      mentionElement   : '.mention-element'
      typeaheadElement : '.typeahead-element'
      sendBtn          : '.bb-message-btn'

    triggers:
      'paste textarea' :
        event: 'new:message:body:paste'
        preventDefault: false
      'click @ui.sendBtn' : 'wrapped:form:submit'

    behaviors:
      Pasteable: { eventName: "new:message:body:paste", attachableType: 'message' }
      Attachable: { attachableType: 'message' }
      MentionArea: {}
      Autocomplete:
        sources: ['users']

    form:
      viewAttributes:
        className: 'form-horizontal'

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        currentUser: @getOption('currentUser')

  class New.Layout extends App.Views.Layout
    template: 'chat/new/layout'
    className: 'col-lg-14 col-md-12'

    regions:
      messageFormRegion: '#message-form-region'
