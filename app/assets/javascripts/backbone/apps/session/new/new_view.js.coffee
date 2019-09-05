@Omega.module "SessionApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Login extends App.Shared.Views.Form
    template: 'session/new/login'
    className: 'box-login'
    modelClassName: 'user'
    preValidate: false

    inputFields: ->
      ['email', 'password']

    ui:
      forgotPasswordBtn: '.bb-forgot-password-btn'

    triggers:
      'click @ui.forgotPasswordBtn' : 'forgot-password:button:clicked'
