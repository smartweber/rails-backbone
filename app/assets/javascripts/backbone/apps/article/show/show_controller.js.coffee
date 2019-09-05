@Omega.module 'ArticleApp.Show', (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options) ->
      @layout     = @getLayoutView()
      @articleType = if options.entityRequestCommand == "get:article:entity"
        'Article'
      else
        'GeneralNewsItem'
      currentUser = App.request "get:current:user"
      article     = App.request options.entityRequestCommand, options.id

      App.execute "when:fetched", [currentUser, article], =>
        @setPageTitle(article)
        @listenTo @layout, 'show', =>
          @middleColumnRegion article, currentUser
          @rightColumnRegion()

        @show @layout

    setPageTitle: (article) ->
      App.execute "set:page:title", @getPageTitle(article)

    getPageTitle: (article) ->
      article.get('title') + ' - Stockharp'

    middleColumnRegion: (article, currentUser) ->
      @middleColumnLayoutView = @getMiddleColumnLayoutView article
      @listenTo @middleColumnLayoutView, 'show', =>
        @feedRegion article.get('id')
        if currentUser.isNew()
          @newUserUIRegion()
        else
          @newPostFormRegion currentUser, article.get('id')
      @layout.middleColumnRegion.show @middleColumnLayoutView

    # TODO: extract shared logic
    newUserUIRegion: ->
      newUserUIView = @getNewUserUIView()

      @listenTo newUserUIView, 'login:button:clicked', ->
        App.navigate Routes.new_user_session_path(), trigger: true

      @listenTo newUserUIView, 'signup:button:clicked', ->
        App.navigate Routes.signup_path(), trigger: true

      @middleColumnLayoutView.newPostFormRegion.show newUserUIView

    newPostFormRegion: (currentUser, articleId) ->
      post = App.request "new:post:entity"
      newPostFormView = @getNewPostFormView post, articleId
      wrappedView = App.request "form:wrapper", newPostFormView,
        multipart: true
        onFormSuccess: (data) =>
          post = App.request "new:post:entity", data
          newPostFormView.$el.find('textarea').val('')
          currentUser.set 'ideas_count', currentUser.get('ideas_count') + 1
          @middleColumnLayoutView.feedRegion.currentView.collection.unshift post

      @listenToOnce newPostFormView.model, 'sync:stop', =>
        @newPostFormRegion currentUser, articleId

      @middleColumnLayoutView.newPostFormRegion.show wrappedView

    feedRegion: (articleId) ->
      feedableType = if @articleType == "Article"
        'article'
      else
        'general_news_item'
      feedComponent = App.request "components:feed",
        id: articleId
        source: feedableType + ':show'
        feedableType: feedableType
        feedableId: articleId

      feedComponent.viewPromise.done (feedView) =>
        @middleColumnLayoutView.feedRegion.show feedView

    rightColumnRegion: ->
      @rightColumnLayoutView = @getRightColumnLayoutView()
      @listenTo @rightColumnLayoutView, 'show', =>
        @footerRegion()
      @layout.rightColumnRegion.show @rightColumnLayoutView

    footerRegion: ->
      footerController = App.request 'footer:controller'
      @rightColumnLayoutView.footerRegion.show footerController.footerView

    getLayoutView: ->
      new Show.Layout

    getMiddleColumnLayoutView: (article) ->
      new Show.MiddleColumnLayout
        model: article

    getRightColumnLayoutView: ->
      new Show.RightColumnLayout

    getNewUserUIView: ->
      new Show.NewUserPostFormReplacement

    getNewPostFormView: (post, articleId) ->
      new Show.NewPostForm
        model: post
        articleId: articleId
        articleType: @articleType
