@Omega.module "UserApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.ContainerLayout extends App.Views.Layout
    template: 'user/new/_container_layout'

    regions:
      benefitsRegion: '#benefits-region'
      signupFormRegion: '#signup-form-region'

    ui:
      loginButton: '.log-in'

    triggers:
      'click @ui.loginButton' : 'login:button:clicked'

  class New.Benefits extends App.Views.ItemView
    template: 'user/new/_benefits'
    className: 'benefits'

  class New.SignupForm extends App.Shared.Views.Form
    template: 'user/new/_signup_form'
    className: "sign-up-block"
    modelClassName: 'user'

    form:
      viewAttributes:
        className: 'signup-form'

    inputFields: ->
      inputNames = ['name', 'username', 'password', 'password_confirmation', 'email']
