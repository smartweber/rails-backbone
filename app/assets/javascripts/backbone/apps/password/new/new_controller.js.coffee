@Omega.module "PasswordApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base
    initialize: ->
      new App.Extensions.BackgroundResize
      user      = App.request "new:user:entity"
      App.execute "when:fetched", user, =>
        user.url  = Routes.user_password_path()
        newPasswordView = @getNewPasswordView user

        formView  = App.request "form:wrapper", newPasswordView,
          onSyncEnd: (entity, jqXHR, textStatus) =>
            switch jqXHR.status
              when 201
                App.execute "reset:instant-messages"
                App.navigate Routes.root_path(), trigger: true, replace: true
              when 401
                App.execute("add:instant-messages", jqXHR.responseJSON["error"])
                @region.currentView.changeErrors entity,
                  email: [jqXHR.responseJSON["error"]]
                ,
                  noMessage: true

        @show formView

    getNewPasswordView: (user) ->
      new New.Password
        model: user
