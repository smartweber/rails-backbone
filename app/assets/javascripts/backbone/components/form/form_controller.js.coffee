@Omega.module "Components.Form", (Form, App, Backbone, Marionette, $, _) ->

  class Form.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options = {}) ->
      @contentView = options.view
      @formLayout  = @getFormLayout options.config

      @listenTo @formLayout, "show", @formContentRegion
      @listenTo @formLayout, "form:submit", => @formSubmit(options.config)
      @listenTo @contentView, "wrapped:form:submit", => @formSubmit(options.config)
      @listenTo @formLayout, "form:cancel", => @formCancel(options.config)

    formCancel: (config) ->
      config.onFormCancel()
      @contentView.triggerMethod "form:cancel"

    formSubmit: (config) ->
      data = Backbone.Syphon.serialize @formLayout
      if @contentView.triggerMethod("form:submit", data) isnt false
        # @contentView.updateModel()
        model = @contentView.model
        collection = @contentView.collection
        @processFormSubmit data, model, collection, config

    processFormSubmit: (data, model, collection, config) ->
      options = { collection: collection }
      _.defaults(options, {callback: config.onFormSuccess}) if config.onFormSuccess
      _.defaults(options, {patch: config.patch}) if config.patch
      if config.onSyncEnd
        @listenTo model, "sync:end", (entity, jqXHR, textStatus) ->
          config.onSyncEnd(entity, jqXHR, textStatus)

      # In case when file fields present
      if config.multipart
        _.defaults(options, @multipartOptions())

      model.save(data, options)

    toFormData: ->
      new FormData @formLayout.$el[0]

    multipartOptions: ->
      data: @toFormData()
      processData: false
      dataType: 'json'
      contentType: false

    onClose: ->
      console.log "onClose", @

    formContentRegion: ->
      @region = @formLayout.formContentRegion
      @show @contentView

    getFormLayout: (options = {}) ->
      config = @getDefaultConfig _.result(@contentView, "form")
      _.extend config, options

      viewAttributes = {config: config, model: @contentView.model, preValidate: @contentView.preValidate}
      _.extend viewAttributes, config.viewAttributes

      new Form.FormWrapper viewAttributes

    getDefaultConfig: (config = {}) ->
      _.defaults config,
        focusFirstInput: false
        errors: true
        syncing: true
        viewAttributes: {}
        onFormSubmit: ->
        onFormCancel: ->
        onFormSuccess: ->
        onSyncEnd: ->

  App.reqres.setHandler "form:wrapper", (contentView, options = {}) ->
    throw new Error "No model found inside of form's contentView" unless contentView.model
    formController = new Form.Controller
      view: contentView
      config: options
    formController.formLayout
