@Omega.module "ArticleApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: 'article/show/layout'

    regions:
      middleColumnRegion: '.middle-column-region'
      rightColumnRegion: '.right-column-region'

  class Show.LeftColumnLayout extends App.Views.Layout
    template: 'article/show/_left_column_layout'
    className: 'col-lg-5 col-md-6'

    regions:
      profileRegion: '.profile-region'

  class Show.MiddleColumnLayout extends App.Views.Layout
    template: 'article/show/_middle_column_layout'
    className: 'col-lg-19 col-md-18'

    regions:
      feedRegion: '.feed-region'
      newPostFormRegion: '.new-post-region'

  class Show.RightColumnLayout extends App.Views.Layout
    template: 'article/show/_right_column_layout'
    className: 'col-lg-5 col-md-6'

    regions:
      footerRegion: '.footer-region'

  class Show.NewPostForm extends App.Shared.Views.NewPostForm
    # TODO: instead of rendering replacement of App.Shared.Views.NewPostForm view - insert the
    # required template inside of App.Shared.Views.NewPostForm's view
    template: 'article/show/_new_post_form'

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        articleId: @getOption('articleId')
        articleType: @getOption('articleType')

  class Show.NewUserPostFormReplacement extends App.Shared.Views.NewUserPostFormReplacement
    template: 'article/show/_new_user_post_form_replacement'
