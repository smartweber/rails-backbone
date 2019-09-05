@Omega.module "PasswordApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Password extends App.Shared.Views.Form
    template: 'password/new/forgot_password'
    className: 'box-login'
    modelClassName: 'user'
    preValidate: true

    inputFields: ->
      ['email']
