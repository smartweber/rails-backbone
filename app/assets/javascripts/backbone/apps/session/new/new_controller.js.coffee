@Omega.module "SessionApp.New", (New, App, Backbone, Marionette, $, _) ->

  class New.Controller extends App.Controllers.Base
    initialize: ->
      new App.Extensions.BackgroundResize
      user      = App.request "new:user:entity"
      App.execute "when:fetched", user, =>
        user.url  = Routes.new_user_session_path()
        loginView = @getLoginView user

        @listenTo loginView, 'forgot-password:button:clicked', ->
          App.navigate Routes.new_user_password_path(), trigger: true

        formView  = App.request "form:wrapper", loginView,
          onSyncEnd: (entity, jqXHR, textStatus) =>
            switch jqXHR.status
              when 200
                App.execute "reset:instant-messages"
                # TODO: allow passing entity, not recreating User model twice as result
                App.execute "set:current:user", _.omit(entity.attributes, 'user')
                App.navigate Routes.command_path(), trigger: true, replace: true
              when 401
                App.execute("add:instant-messages", jqXHR.responseJSON["error"])
                @region.currentView.changeErrors entity,
                  email: [jqXHR.responseJSON["error"]]
                  password: [jqXHR.responseJSON["error"]]
                ,
                  noMessage: true

        @show formView

    getLoginView: (user) ->
      new New.Login
        model: user
