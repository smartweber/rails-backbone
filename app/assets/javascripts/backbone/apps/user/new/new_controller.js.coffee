@Omega.module "UserApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base
    initialize: ->
      new App.Extensions.BackgroundResize
      @layout = @getContainerLayout()

      @listenTo @layout, 'login:button:clicked', ->
        App.navigate Routes.new_user_session_path(), trigger: true

      @listenTo @layout, 'show', =>
        @benefitsRegion()
        @signupFormRegion()

      @show @layout

    benefitsRegion: ->
      benefitsView = @getBenefitsView()

      @layout.benefitsRegion.show benefitsView

    signupFormRegion: ->
      newUser     = App.request "new:user:entity"
      signupView  = @getSignupView newUser

      wrappedForm = App.request "form:wrapper", signupView,
        onFormSuccess: (data) ->
          App.execute "set:current:user", _.omit(data, 'session')
          App.navigate Routes.command_path(), trigger: true, replace: true

      @layout.signupFormRegion.show wrappedForm

    getContainerLayout: ->
      new New.ContainerLayout

    getBenefitsView: ->
      new New.Benefits

    getSignupView: (newUser) ->
      new New.SignupForm
        model: newUser


