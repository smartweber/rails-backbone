@Omega.module "UserApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base
    disableTitleAutoSetting: true

    initialize: (options) ->
      @layout = @getLayoutView()
      user = App.request("user:entity", options.username)
      currentUser = App.request("get:current:user")

      App.execute "when:fetched", [user, currentUser], =>
        @setPageTitle(user)

        @listenTo @layout, 'show', =>
          @leftColumnRegion user
          @middleColumnRegion user
          @rightColumnRegion user, currentUser

        @show @layout
        @executeExtraFunctions()

    setPageTitle: (user) ->
      App.execute "set:page:title", @pageTitle(user)

    pageTitle: (user) ->
      "#{user.get('name')} (#{user.get('username')}) | Stockharp"

    leftColumnRegion: (user) ->
      userInfoView = @getUserInfoView user

      @listenTo userInfoView, 'section:link:clicked', (e) =>
        App.navigate $(e.target).attr('href'), replace: true
        setTimeout (=>
          @handleUrlHash()
        ), 0

      @layout.leftColumnRegion.show userInfoView

    middleColumnRegion: (user) ->
      @middleColumnLayoutView = @getMiddleColumnView user
      @listenTo @middleColumnLayoutView, 'show', =>
        @feedRegion user
        @aboutRegion user
        @investorInfoRegion user
        @radarRegion user
        @friendsRegion user
        @followingRegion user
        @followersRegion user
        @handleUrlHash()
      @layout.middleColumnRegion.show @middleColumnLayoutView

    handleUrlHash: ->
      if Backbone.history.location.hash
        @middleColumnLayoutView.$el.find("a[href=#{Backbone.history.location.hash}]").click()

    feedRegion: (user) ->
      feedComponent = App.request "components:feed",
        id: user.id
        source: 'user:show'
        emptyView: Show.EmptyFeed
        feedableType: 'user'
        feedableId: user.id

      feedComponent.viewPromise.done (feedView) =>
        @middleColumnLayoutView.feedRegion.show feedView

    aboutRegion: (user) ->
      aboutView = @getAboutView user
      @middleColumnLayoutView.aboutRegion.show aboutView

    investorInfoRegion: (user) ->
      investorInfoView = @getInvestorInfoView user
      @middleColumnLayoutView.investorInfoRegion.show investorInfoView

    radarRegion: (user) ->
      radarView = @getRadarView user
      @middleColumnLayoutView.radarRegion.show radarView

    friendsRegion: (user) ->
      friendsView = @getFriendsView user
      @middleColumnLayoutView.friendsRegion.show friendsView

    followingRegion: (user) ->
      followingView = @getFollowingView user
      @middleColumnLayoutView.followingRegion.show followingView

    followersRegion: (user) ->
      followersView = @getFollowersView user
      @middleColumnLayoutView.followersRegion.show followersView

    footerRegion: ->
      footerController = App.request 'footer:controller'
      @rightColumnLayoutView.footerRegion.show footerController.footerView

    rightColumnRegion: (user, currentUser) ->
      @rightColumnLayoutView = @getRightColumnLayoutView()
      @listenTo @rightColumnLayoutView, 'show', =>
        unless currentUser.id == user.id
          @socialUIRegion user, currentUser
        @footerRegion()
      @layout.rightColumnRegion.show @rightColumnLayoutView

    socialUIRegion: (user, currentUser) ->
      socialUIView = @getSocialUIView user

      # TODO: refactor this
      @listenTo socialUIView, 'follow:button:clicked', (args) ->
        relationship = args.model.get('relationship')
        if relationship.isNew()
          relationship.save null,
            success: ->
              args.model.set followers_count: args.model.get('followers_count') + 1
              currentUser.set following_users_count: currentUser.get('following_users_count') + 1
        else
          relationship.destroy success: (model, response) ->
            relationship = App.request "new:relationship:entity", args.model
            args.model.set
              relationship: relationship
              followers_count: args.model.get('followers_count') - 1
            currentUser.set following_users_count: currentUser.get('following_users_count') - 1

      @rightColumnLayoutView.socialUIRegion.show socialUIView

    profileWidgetRegion: (user) ->
      profileWidgetView = @getProfileWidgetView user
      @rightColumnLayoutView.profileWidgetRegion.show profileWidgetView

    favoriteStocksRegion: ->
      favoriteStocksView = @getFavoriteStocksView()
      @rightColumnLayoutView.favoriteStocksRegion.show favoriteStocksView

    getLayoutView: ->
      new Show.Layout

    getUserInfoView: (user) ->
      new App.Shared.Views.Profile
        model: user

    getRightColumnLayoutView: ->
      new Show.RightColumnLayout

    getMiddleColumnView: (user) ->
      new Show.MiddleColumnLayout
        model: user

    getAboutView: (user) ->
      new Show.About
        model: user

    getInvestorInfoView: (user) ->
      new Show.InvestorInfo
        model: user

    getRadarView: (user) ->
      new Show.Radar
        model: user

    getFriendsView: (user) ->
      new Show.Friends
        model: user

    getFollowingView: (user) ->
      new Show.Following
        model: user

    getFollowersView: (user) ->
      new Show.Followers
        model: user

    getProfileWidgetView: (user) ->
      new Show.ProfileWidget
        model: user

    getFavoriteStocksView: ->
      new Show.FavoriteStocks

    getSocialUIView: (user) ->
      new Show.SocialUI
        model: user

    executeExtraFunctions: ->

      check_width = (elem) ->
        elem.outerWidth()

      positionate_cols = () ->
        if check_width($('.profile-page .container')) == 970
          left_col_height = $('#left-column-region').parent('div').outerHeight(true)
          $('#right-column-region > div').css top: left_col_height
        else
          $('#right-column-region > div').css top: 0

      $ ->
        $('.edit-profile-option').on 'click', (e) ->
          e.preventDefault
          $(this).parents('.profile-option').find('p').hide()
          $(this).parents('.profile-option').find('.inputs').show()
          return

        positionate_cols()

        $(window).resize ->
          positionate_cols()
