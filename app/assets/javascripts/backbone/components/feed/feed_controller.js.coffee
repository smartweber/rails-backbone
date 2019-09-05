@Omega.module "Components.Feed", (Feed, App, Backbone, Marionette, $, _) ->

  class Feed.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options) ->
      @postsObjId    = options.id
      @feedSource    = "#{options.source}:feed"
      @page          = 1
      @feedableId    = options.feedableId
      @feedableType  = options.feedableType
      @feed          = App.request @feedSource, @page, @postsObjId
      @viewPromise   = $.Deferred()
      currentUser    = App.request "get:current:user"

      App.execute "when:fetched", @feed, =>
        @postsRegion options.maxCommentsPerPost, currentUser, options.emptyView

    postsRegion: (maxCommentsPerPost, currentUser, emptyView) ->
      postsView = @getPostsView maxCommentsPerPost, currentUser, emptyView

      @listenTo postsView, "childview:favorite:post:button:clicked", (child, args) ->
        model = child.model
        if model.get('favorited') then model.removeFromFavorites() else model.addToFavorites()

      @listenTo postsView, "childview:list:comments:button:clicked", (child, args) ->
        requestParams = {data: {commentable_type: 'Post', commentable_id: child.model.get('id')}}
        child.commentsRegion.currentView.collection.fetch(requestParams).done =>
          child.uiRegion.empty()

      @listenTo postsView, "childview:like:link:clicked", (postView, view) ->
        view.model.like()

      @listenTo postsView, 'childview:unlike:link:clicked', (postView, view) ->
        view.model.unlike()

      _.each ['childview:comment:content:link:clicked', 'childview:post:content:link:clicked'], (trigger) =>
        @listenTo postsView, trigger, (child, event) ->
          App.navigate $(event.target).attr('href'), trigger: true

      @listenTo postsView, "childview:delete:post:link:clicked", (child, args) ->
        child.model.destroy()

      @listenTo postsView, "childview:comment:delete:button:clicked", (child, commentView) ->
        commentView.model.destroy()

      @listenTo postsView, "childview:attachment:delete:button:clicked", (child, attachmentView) ->
        attachmentView.model.destroy()

      _.each ["childview:post:username:link:clicked", "childview:comment:username:link:clicked"], (trigger) =>
        @listenTo postsView, trigger, (child, args) ->
          App.navigate Routes.user_path(args.model.get('user').username), trigger: true

      @listenTo postsView, 'childview:send:comment:key:pressed', (child, wrapperView) ->
        wrapperView.trigger('form:submit')

      @listenTo postsView, 'fetch:new:posts:link:clicked', (args) =>
        postsView.removeNewPostsCounter()
        @feed.addNewPosts()

      # TODO: figure out proper unbinding mechanics
      $(window).on "scroll", =>
        wintop         = $(window).scrollTop()
        winheight      = $(window).height()
        docheight      = $(document).height()
        scrolltrigger  = 0.95
        @timeoutPassed ?= true
        if (wintop / (docheight - winheight)) > scrolltrigger
          if (not @extraPosts? or @extraPosts?._fetch.readyState == 4) and @timeoutPassed
            @timeoutPassed = false
            @page += 1

            @extraPosts = App.request @feedSource, @page, @postsObjId
            App.execute "when:fetched", @extraPosts, =>
              if @extraPosts.length > 0
                posts.add(@extraPosts.models)
              else
                $(window).off('scroll')
              setTimeout (=>
                @timeoutPassed = true
              ), 3000

      App.execute "websocket:subscribe:to:feed", @feedableType, @feedableId

      App.vent.on "feeds:#{@feedableType}:#{@feedableId}:update:received", (message) =>
        console.log "Message arrived is ", message
        @feed.updateWith(message)

      @viewPromise.resolve(postsView)

    getPostsView: (maxCommentsPerPost, currentUser, emptyView) ->
      new Feed.Posts
        feed: @feed
        collection: @feed.get('posts')
        maxCommentsPerPost: maxCommentsPerPost
        currentUser: currentUser
        emptyView: emptyView

  App.reqres.setHandler "components:feed", (options) ->
    throw new Error "No source property specified" unless options.source
    # TODO: that's pretty lame, should just pass options and mergeOptions instead
    new Feed.Controller
      id: options.id
      feedableId: options.feedableId
      feedableType: options.feedableType
      source: options.source
      maxCommentsPerPost: options.maxCommentsPerPost
      emptyView: options.emptyView
