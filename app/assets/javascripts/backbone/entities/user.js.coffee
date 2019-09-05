@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.User extends App.Entities.Model
    urlRoot: -> Routes.api_users_path()

    validation:
      name:
        required: true
        maxLength: 50
        pattern: 'name'
      username:
        required: true
        minLength: 4
        maxLength: 15
        pattern: 'username'
      password:
        required: true
        minLength: 8
      password_confirmation:
        required: true
        equalToFormInput: 'password'
      email:
        required: true
        pattern: 'email'
        maxLength: 100
      tos_and_pp_accepted:
        checkboxSet: true

    to_param: ->
      @get('username')

    can: (action, resource) ->
      @get('id') == if resource.user_id? then resource.user_id else resource.user?.id

    hasAccessTo: (fragment, args) ->
      fragment = s(fragment).rtrim('/').value()
      alwaysPermittedRoutes = [Routes.new_user_session_path(), Routes.destroy_user_session_path(), Routes.root_path(), Routes.new_user_registration_path(), Routes.new_user_password_path()]
      if args[0]
        alwaysPermittedRoutes = _.union alwaysPermittedRoutes, [Routes.article_path(args[0]), Routes.news_article_path(args[0]), Routes.company_path(args[0]), Routes.user_path(args[0]),
        Routes.edit_user_password_path(reset_password_token: args[0])]
      urlFragment = '/' + fragment
      if not App.currentUser.isNew() or _.contains(alwaysPermittedRoutes, urlFragment)
        true
      else
        false

  API =
    getUser: (username) ->
      user = new Entities.User
        id: username
      user.fetch()
      user

    newUser: (attributes) ->
      user = new Entities.User attributes
      user

  App.reqres.setHandler "user:entity", (username) ->
    API.getUser username

  App.reqres.setHandler "new:user:entity", (attributes) ->
    API.newUser attributes
