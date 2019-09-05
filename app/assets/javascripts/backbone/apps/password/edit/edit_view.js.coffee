@Omega.module "PasswordApp.Edit", (Edit, App, Backbone, Marionette, $, _) ->

  class Edit.Password extends App.Shared.Views.Form
    template: 'password/edit/update_password'
    className: 'box-login'
    modelClassName: 'user'
    preValidate: true

    inputFields: ->
      ['password', 'password_confirmation']


    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        resetToken: @getOption('resetToken')
