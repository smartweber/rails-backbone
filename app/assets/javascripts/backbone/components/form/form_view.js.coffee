@Omega.module "Components.Form", (Form, App, Backbone, Marionette, $, _) ->

  class Form.FormWrapper extends App.Views.Layout
    template: "form/form"

    tagName: "form"
    attributes: ->
      "data-type": @getFormDataType()

    regions:
      formContentRegion: "#form-content-region"

    triggers:
      "submit"                            : "form:submit"
      "click [data-form-button='cancel']" : "form:cancel"

    modelEvents:
      "change:_errors"  : "changeErrors"
      "sync:start"      : "syncStart"
      "sync:stop"       : "syncStop"

    initialize: (options) ->
      @setInstancePropertiesFor "config"
      if @options.preValidate
        @listenTo this, 'render', @setupValidation

    delegateEvents: (events) ->
      @ui = _.extend @_baseUI(), _.result(this, 'ui')
      if @options.preValidate
        @events = _.extend @_validationEvents(), _.result(this, 'events')
      super events

    _baseUI: ->
      submit: 'input[type="submit"]'

    _validationEvents: ->
      eventHash =
        'paste [data-validation]': @waitAndValidateField
        'change [data-validation]': @validateField
        'blur [data-validation]':   @validateField

    onShow: ->
      _.defer =>
        @focusFirstInput() if @config.focusFirstInput

    focusFirstInput: ->
      @$(":input:visible:enabled:first").focus()

    getFormDataType: ->
      if @model.isNew() then "new" else "edit"

    waitAndValidateField: (e) ->
      setTimeout (=>
        @validateField(e)
      ), 0

    validateField: (e) ->
      validation = $(e.target).attr('data-validation')
      value = $(e.target).val()
      errorMessage = @model.preValidate validation, value
      if errorMessage
        @invalid @, validation, errorMessage
      else
        @valid @, validation

    setupValidation: ->
      Backbone.Validation.unbind this
      Backbone.Validation.bind this,
        valid: @valid
        invalid: @invalid

    changeErrors: (model, errors, options) ->
      if _.isEmpty(errors) then @removeErrors() else @addErrors(errors, options)

    addErrors: (errors = {}, options) ->
      for name, array of errors
        el = @$("[data-validation=#{name}]")
        @addError el, array[0], options

    addError: (el, error, options) ->
      @removeSuccessClass(el)
      unless @hasError(el)
        unless options?.noMessage and options.noMessage == true
          errorMsg = $("<small>").text(error)
          @addErrorClass(el).append(errorMsg)
        else
          @addErrorClass(el)

    hasError: (el) ->
      el.next('small').length > 0

    addErrorClass: (el) ->
      el.parent()
        .addClass('has-error')

    addSuccessClass: (el) ->
      el.parent()
        .addClass('has-success')

    removeSuccessClass: (el) ->
      el.parent()
        .removeClass('has-success')

    removeErrorClass: (el) ->
      el.parent()
        .removeClass('has-error')

    removeErrors: (fields) ->
      if _.isEmpty(fields)
        fields = @$("[data-validation]")
      _.each _.flatten([fields]), (el) =>
        @removeErrorClass(el)
        el.nextAll('small').remove()

    valid: (view, attr, selector) =>
      el = @$("[data-validation=#{attr}]")
      @removeErrors(el)
      @addSuccessClass(el)

    invalid: (view, attr, error, selector) =>
      el = @$("[data-validation=#{attr}]")
      @removeErrors(el)
      @addError(el, error)
      @removeSuccessClass(el)

    syncStart: (model) ->
      # @addOpacityWrapper() if @config.syncing

    syncStop: (model) ->
      # @addOpacityWrapper(false) if @config.syncing
