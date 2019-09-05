@Omega.module "UserApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Layout extends App.Views.Layout
    template: 'user/show/layout'

    regions:
      leftColumnRegion:   '#left-column-region'
      middleColumnRegion: '#middle-column-region'
      rightColumnRegion:  '#right-column-region'

  class Show.UserInfo extends App.Views.ItemView
    template: 'user/show/_user_info'

  class Show.RightColumnLayout extends App.Views.Layout
    template: 'user/show/_right_column_layout'
    className: 'col-md-6 col-md-push-18 col-lg-5 col-lg-push-0 '

    regions:
      socialUIRegion: '#social-ui-region'
      footerRegion: '#footer-region'

  class Show.SocialUI extends App.Views.ItemView
    template: 'user/show/_social_ui'
    className: 'well well-profile buttons-container-on-side'

    triggers:
      'click .bb-follow-user' : 'follow:button:clicked'

    modelEvents:
      'change:followers_count' : 'render'

    initialize: ->
      relationship = App.request "new:relationship:entity", @model
      @model.set relationship: relationship

  class Show.ProfileWidget extends App.Views.ItemView
    template: 'user/show/_profile_widget'
    className: 'widget-box profile-widget'

  class Show.FavoriteStocks extends App.Views.ItemView
    template: 'user/show/_favorite_stocks'
    className: 'widget-box favorite-stocks'

  class Show.MiddleColumnLayout extends App.Views.Layout
    template: 'user/show/_middle_column_layout'
    className: 'col-md-18 col-md-pull-6 col-lg-14 col-lg-pull-0'

    regions:
      feedRegion: '.feed-region'
      aboutRegion: '.about-region'
      investorInfoRegion: '.investor-info-region'
      radarRegion: '.radar-region'
      friendsRegion: '.friends-region'
      followersRegion: '.followers-region'
      followingRegion: '.following-region'

    events:
      'click [role=tab]': 'onClickTab'

    onClickTab: (event) ->
      targetTabPaneId = event.target.getAttribute('href');

      @$el.find('.nav >li.active').removeClass('active')
      @$el.find('.tab-pane.active').removeClass('active') 
      
      $(event.target).parent().addClass('active')
      @$el.find(targetTabPaneId).addClass('active')

  class Show.EmptyFeed extends App.Views.ItemView
    template: 'user/show/_empty_feed'
    className: 'panel panel-default sh-panel'

  class Show.About extends App.Views.ItemView
    template: 'user/show/_about'
    className: 'panel panel-default sh-panel'

  class Show.InvestorInfo extends App.Views.ItemView
    template: 'user/show/_investor_info'
    className: 'panel panel-default sh-panel'

  class Show.Radar extends App.Views.ItemView
    template: 'user/show/_radar'
    className: 'panel panel-default sh-panel'

  class Show.Friends extends App.Views.ItemView
    template: 'user/show/_friends'
    className: 'panel panel-default sh-panel'

  class Show.Following extends App.Views.ItemView
    template: 'user/show/_following'
    className: 'panel panel-default sh-panel'

  class Show.Followers extends App.Views.ItemView
    template: 'user/show/_followers'
    className: 'panel panel-default sh-panel'
