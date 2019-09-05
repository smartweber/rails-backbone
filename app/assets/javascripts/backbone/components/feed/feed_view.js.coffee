@Omega.module "Components.Feed", (Feed, App, Backbone, Marionette, $, _) ->

  class Feed.Layout extends App.Views.Layout
    template: "feed/feed_layout"

    regions:
      postsRegion: "#posts-region"

  class Feed.ReplyLayout extends App.Shared.Views.Form
    template: 'shared/posts/_reply_layout'
    className: 'panel-footer sh-panel-footer-reply bb-reply-form'
    modelClassName: 'comment'

    ui:
      mentionElement: '.bb-mention-element'
      inputBox: 'textarea'
      slidableElement: 'textarea'

    triggers:
      'paste @ui.inputBox' :
        event: 'new:comment:body:paste'
        preventDefault: false

    events:
      'keypress @ui.inputBox' : 'keypressOnInputBox'

    regions:
      attachmentsRegion: '.reply-attachments-region'

    behaviors:
      Pasteable: { eventName: "new:comment:body:paste", attachableType: 'comment' }
      Attachable: { attachableType: 'comment' }
      Slidable: {}
      MentionArea: {}

    inputFields: ->
      ['body']

    keypressOnInputBox: (event) ->
      if event.keyCode == 13
        @trigger 'send:comment:key:pressed', @

  class Feed.Post extends App.Views.ItemView
    template: 'shared/posts/_post'

    ui:
      internalLink: '.bb-post-link'
      usernameLink: '.bb-user-link'
      removeLink:   '.bb-delete-post'

    events:
      'click @ui.internalLink' : 'onLinkClicked'

    triggers:
      'click @ui.usernameLink' : 'post:username:link:clicked'

    onLinkClicked: (e) ->
      e.preventDefault()
      @trigger 'post:content:link:clicked', e

  class Feed.Attachment extends App.Views.ItemView
    template: 'shared/posts/_attachment'
    className: 'upload'

  class Feed.Attachments extends App.Views.CollectionView
    childView: Feed.Attachment

  class Feed.CommentContent extends App.Views.ItemView
    template: 'shared/comments/_content'

    ui:
      internalLink: '.bb-post-link'
      usernameLink: '.bb-user-link'

    events:
      'click @ui.internalLink' : 'onLinkClicked'

    triggers:
      'click @ui.usernameLink' : 'username:link:clicked'

    initialize: ->
      like = App.request "new:like:entity", @model
      @model.set like: like

    onLinkClicked: (e) ->
      e.preventDefault()
      @trigger 'comment:content:link:clicked', e

    onRender: ->
      @$el.find("time.timeago").timeago()

  class Feed.CommentFooter extends App.Views.ItemView
    template: 'shared/comments/_footer'

  class Feed.CommentLayout extends App.Views.Layout
    template: 'shared/comments/_comment_layout'
    className: 'panel-body panel-body-comments reply'

    triggers:
      'click .bb-delete-comment' : 'comment:delete:button:clicked'
      'click .bb-like-link'      : 'like:link:clicked'
      'click .bb-unlike-link'    : 'unlike:link:clicked'

    modelEvents:
      'change:likes_count' : 'updateLikes'

    regions:
      contentRegion: '.content-region'
      uiRegion: '.comment-ui-region'
      attachmentsRegion: '.attachments-region'

    onRender: ->
      attachments = App.request "new:attachment:entities", @model.get('attachments')

      contentView = new Feed.CommentContent
        model: @model
      uiView = new Feed.CommentUI
        model: @model
      attachmentsView = new Feed.Attachments
        collection: attachments

      @listenTo attachmentsView, 'childview:attachment:delete:button:clicked', (child, args) ->
        @trigger 'attachment:delete:button:clicked', child

      @listenTo contentView, 'username:link:clicked', (args) ->
        @trigger 'comment:username:link:clicked', args

      @listenTo contentView, 'comment:content:link:clicked', (event) ->
        @trigger 'comment:content:link:clicked', event

      @contentRegion.show contentView
      @uiRegion.show uiView
      @attachmentsRegion.show attachmentsView

    updateLikes: (model, value) ->
      @uiRegion.currentView.render()

  class Feed.Comments extends App.Views.CollectionView
    childView: Feed.CommentLayout

    childEvents:
      'like:link:clicked': (view, args) ->
        @trigger 'like:link:clicked', view, args.view
      'unlike:link:clicked': (view, args) ->
        @trigger 'unlike:link:clicked', view, args.view

    onAddChild: ->
      # If all childrens are rendered
      if @children.length == @collection.length
        @$el.find("time.timeago").timeago()

  class Feed.CommentUI extends App.Views.ItemView
    template: 'shared/comments/_comment_ui'
    className: 'comments-info'

  class Feed.PostUI extends App.Views.ItemView
    template: 'shared/posts/_post_ui'
    className: 'comments-info'

  class Feed.PostLayout extends App.Views.Layout
    template: 'shared/posts/_post_layout'
    className: 'panel panel-default sh-panel'

    regions:
      postRegion: '.post-region'
      commentsRegion: '.comments-region'
      attachmentsRegion: '.attachments-region'
      uiRegion: '.ui-region'
      replyRegion: '.reply-region'

    ui:
      likeLink: '.bb-like-link'
      unlikeLink: '.bb-unlike-link'

    triggers:
      'click @ui.likeLink'      : 'like:link:clicked'
      'click @ui.unlikeLink'    : 'unlike:link:clicked'
      'click .see-all-comments' : 'list:comments:button:clicked'
      'click .new-comment .btn' : 'create:comment:button:clicked'
      'click .add-to-favorites' : 'favorite:post:button:clicked'
      'click .bb-delete-post'   : 'delete:post:link:clicked'

    modelEvents:
      'change:favorited'      : 'renderUI'
      'change:likes_count'    : 'renderUI'
      'change:comments_count' : 'renderUI'

    initialize: ->
      like = App.request "new:like:entity", @model
      @model.set like: like

    onRender: ->
      reversedModels = @model.get('comments').models.reverse()
      # TODO(!!!): view interferes with model logic
      @model.get('comments').models = reversedModels
      maxCommentsPerPost = if @getOption('maxCommentsPerPost')? then @getOption('maxCommentsPerPost') else 3

      postView = new Feed.Post
        model: @model
      commentsView = new Feed.Comments
        collection: @model.get('comments')
        model: @model
      attachmentsView = new Feed.Attachments
        collection: @model.get('attachments')
      postUIView = new Feed.PostUI
        model: @model
      unless @getOption('currentUser').isNew()
        # TODO: some bullshit happens here
        newComment = App.request "new:comment:entity:for", @model, @model
        replyLayoutView = new Feed.ReplyLayout
          model: newComment

        wrappedFormView = App.request 'form:wrapper', replyLayoutView,
          multipart: true
          onFormSuccess: (data) =>
            comment = App.request "new:comment:entity:from:attributes", data
            @model.get('comments').add comment
            @render()

        @listenTo wrappedFormView.formContentRegion, 'show', (view) ->
          @listenTo view, 'send:comment:key:pressed', (view) ->
            @trigger 'send:comment:key:pressed', wrappedFormView

        @replyRegion.show wrappedFormView

      # TODO: maybe we can use attachReraisingEvents() instead
      @listenTo commentsView, 'childview:comment:delete:button:clicked', (child, args) ->
        @trigger 'comment:delete:button:clicked', child

      @listenTo commentsView, 'childview:attachment:delete:button:clicked', (child, attachmentView) ->
        @trigger 'attachment:delete:button:clicked', attachmentView

      @listenTo commentsView, 'childview:comment:content:link:clicked', (child, event) ->
        @trigger 'comment:content:link:clicked', child, event

      @listenTo commentsView, 'childview:comment:username:link:clicked', (child, args) ->
        @trigger 'comment:username:link:clicked', args

      @listenTo postView, 'post:username:link:clicked', (args) ->
        @trigger 'post:username:link:clicked', args

      @listenTo postView, 'post:content:link:clicked', (e) ->
        @trigger 'post:content:link:clicked', e

      @attachReraisingEvents(e, commentsView) for e in ["like:link:clicked", "unlike:link:clicked"]

      @postRegion.show postView
      @attachmentsRegion.show attachmentsView
      @uiRegion.show postUIView
      @commentsRegion.show commentsView

    attachReraisingEvents: (e, view) ->
      @listenTo view, e, (view) ->
        @trigger e, view

    renderUI: ->
      @uiRegion.currentView.render()

  class Feed.Posts extends App.Views.CollectionView
    childView: Feed.PostLayout

    initialize: ->
      @listenTo @getOption('feed'), 'change:unseen_posts', @displayNewPostsCounter
      @listenTo @getOption('feed'), 'change:posts', @render

    getEmptyView: ->
      @getOption('emptyView')

    triggers:
      'click .bb-fetch-new-posts': 'fetch:new:posts:link:clicked'

    displayNewPostsCounter: ->
      return true unless @getOption('feed').get('unseen_posts') > 0
      template = "<div class='alert alert-info bb-fetch-new-posts'>There's #{@getOption('feed').get('unseen_posts')} new posts. Click to see them.</div>"
      alertBox = @$el.find('.bb-fetch-new-posts')
      if alertBox.length > 0
        alertBox.replaceWith(template)
      else
        @$el.find('div:first').before(template)

    removeNewPostsCounter: ->
      @$el.find('.bb-fetch-new-posts').remove()

    childViewOptions: (model, index) ->
      {
        maxCommentsPerPost: @getOption('maxCommentsPerPost')
        currentUser: @getOption('currentUser')
      }

    onAddChild: ->
      # If all childrens are rendered
      if @children.length == @collection.length
        @$el.find("time.timeago").timeago()
