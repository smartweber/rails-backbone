@Omega.module "PasswordApp.Edit", (Edit, App, Backbone, Marionette, $, _) ->

  class Edit.Controller extends App.Controllers.Base
    initialize: (options) ->
      new App.Extensions.BackgroundResize
      user        = App.request "new:user:entity"
      App.execute "when:fetched", user, =>
        user.url  = Routes.user_password_path()
        user.set('id', -1)
        editPasswordView = @getEditPasswordView user, options.resetToken

        formView  = App.request "form:wrapper", editPasswordView,
          patch: true
          onSyncEnd: (entity, jqXHR, textStatus) =>
            switch jqXHR.status
              when 200
                App.execute "reset:instant-messages", 'Password is updated'
                App.execute "set:current:user", _.omit(entity.attributes, 'user')
                App.navigate Routes.command_path(), trigger: true, replace: true
              when 422
                App.execute("add:instant-messages", jqXHR.responseText)
                @region.currentView.changeErrors entity,
                  email: [jqXHR.responseJSON["error"]]
                ,
                  noMessage: true

        @show formView

    getEditPasswordView: (user, resetToken) ->
      new Edit.Password
        model: user
        resetToken: resetToken
