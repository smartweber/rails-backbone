@Omega.module "ChannelApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: 'channel/show/layout'

    regions:
      leftColumnRegion: '.left-column-region'
      middleColumnRegion: '.middle-column-region'
      rightColumnRegion: '.right-column-region'

  class Show.LeftColumnLayout extends App.Views.Layout
    template: 'channel/show/_left_column_layout'
    className: 'col-lg-5 col-md-6'

    regions:
      profileRegion: '.profile-region'

  class Show.MiddleColumnLayout extends App.Views.Layout
    template: 'channel/show/_middle_column_layout'
    className: 'col-lg-14 col-md-12'

    regions:
      feedRegion: '.feed-region'

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        channelName: @getOption('channelName')

  class Show.RightColumnLayout extends App.Views.Layout
    template: 'channel/show/_right_column_layout'
    className: 'col-lg-5 col-md-6'

    regions:
      footerRegion: '.footer-region'
