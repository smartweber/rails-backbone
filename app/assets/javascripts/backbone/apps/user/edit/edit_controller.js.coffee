@Omega.module "UserApp.Edit", (Edit, App, Backbone, Marionette, $, _) ->

  class Edit.Controller extends App.Controllers.Base
    initialize: ->
      user  = App.request 'get:current:user'
      newsArticles = App.request "get:news:articles"
      @layout      = @getLayoutView()

      App.execute "when:fetched", newsArticles, =>
        @listenTo @layout, 'show', ->
          @leftColumnRegion user
          @middleColumnRegion user
          @rightColumnRegion newsArticles

        @show @layout

    rightColumnRegion: (newsArticles) ->
      @rightColumnLayoutView = @getRightColumnLayoutView()

      @listenTo @rightColumnLayoutView, 'show', =>
        @marketSnapshotRegion()
        @marketHeadlinesRegion newsArticles
        @userRecommendationsRegion()

      @layout.rightColumnRegion.show @rightColumnLayoutView

    userRecommendationsRegion: ->
      userRecommendationsView = @getUserRecommendationsView()
      @rightColumnLayoutView.userRecommendationsRegion.show userRecommendationsView

    marketHeadlinesRegion: (newsArticles) ->
      marketHeadlinesView = @getMarketHeadlinesView newsArticles

      _.each ['next:page:link:clicked', 'prev:page:link:clicked'], (event) =>
        @listenTo marketHeadlinesView, event, ->
          marketHeadlinesView.toggleLinks()
          newsArticles.page += if _.isEmpty(event.match(/next/)) then -1 else 1
          newsArticles.fetch({ data: {page: newsArticles.page}, reset: true })

      @rightColumnLayoutView.marketHeadlinesRegion.show marketHeadlinesView

    marketSnapshotRegion: ->
      marketSnapshotView = @getMarketSnapshotView()
      @rightColumnLayoutView.marketSnapshotRegion.show marketSnapshotView

    middleColumnRegion: (user) ->
      @middleColumnLayoutView = @getMiddleColumnLayoutView()

      @listenTo @middleColumnLayoutView, 'show', =>
        @generalTabRegion user
        @securityTabRegion user
        @blockedAccountsTabRegion()
        @notificationsTabRegion()

      @layout.middleColumnRegion.show @middleColumnLayoutView

    notificationsTabRegion: ->
      notificationsTabView = @getNotificationsTabView()
      @middleColumnLayoutView.notificationsTabRegion.show notificationsTabView

    blockedAccountsTabRegion: (user) ->
      blockedAccountsTabView = @getBlockedAccountsTabView user
      @middleColumnLayoutView.blockedAccountsTabRegion.show blockedAccountsTabView

    securityTabRegion: (user) ->
      @securityTabLayoutView = @getSecurityTabLayoutView()

      @listenTo @securityTabLayoutView, 'show', =>
        @securitySettingsFormRegion user

      @middleColumnLayoutView.securityTabRegion.show @securityTabLayoutView

    securitySettingsFormRegion: (user) ->
      securitySettingsFormView = @getSecuritySettingsFormView user
      wrappedView = App.request "form:wrapper", securitySettingsFormView,
        onFormSuccess: (data) =>
          console.log 'security settings saved'

      @securityTabLayoutView.securitySettingsFormRegion.show wrappedView

    generalTabRegion: (user) ->
      @generalTabLayoutView = @getGeneralTabLayoutView()

      @listenTo @generalTabLayoutView, 'show', =>
        @generalSettingsFormRegion user
        @accountDeactivationFormRegion user

      @middleColumnLayoutView.generalTabRegion.show @generalTabLayoutView

    generalSettingsFormRegion: (user) ->
      generalSettingsFormView = @getGeneralSettingsFormView user
      wrappedView = App.request "form:wrapper", generalSettingsFormView,
        patch: true
        multipart: true

      @generalTabLayoutView.generalSettingsFormRegion.show wrappedView

    accountDeactivationFormRegion: (user) ->
      accountDeactivationFormView = @getAccountDeactivationFormView user
      wrappedView = App.request "form:wrapper", accountDeactivationFormView,
        onFormSuccess: (data) =>
          console.log 'deactivation success'

      @generalTabLayoutView.accountDeactivationFormRegion.show wrappedView

    leftColumnRegion: (user) ->
      @leftColumnLayoutView = @getLeftColumnLayoutView()

      @listenTo @leftColumnLayoutView, 'show', =>
        @userInfoRegion user
        @navigationRegion()

      @layout.leftColumnRegion.show @leftColumnLayoutView

    userInfoRegion: (user) ->
      userInfoView = @getUserInfoView user
      @leftColumnLayoutView.userInfoRegion.show userInfoView

    navigationRegion: ->
      navigationView = @getNavigationView()
      @leftColumnLayoutView.navigationRegion.show navigationView

    getNotificationsTabView: ->
      new Edit.NotificationsTab

    getUserRecommendationsView: ->
      new App.Shared.Views.UserFollowRecommendations

    getMarketHeadlinesView: (newsArticles) ->
      new App.Shared.Views.MarketHeadlines
        collection: newsArticles

    getMarketSnapshotView: ->
      new App.Shared.Views.MarketSnapshot

    getRightColumnLayoutView: ->
      new Edit.RightColumnLayout

    getBlockedAccountsTabView: (user) ->
      new Edit.BlockedAccountsTab
        model: user

    getSecurityTabLayoutView: ->
      new Edit.SecurityTabLayout

    getSecuritySettingsFormView: (user) ->
      new Edit.SecuritySettingsForm
        model: user

    getGeneralTabLayoutView: ->
      new Edit.GeneralTabLayout

    getGeneralSettingsFormView: (user) ->
      new Edit.GeneralSettingsForm
        model: user

    getAccountDeactivationFormView: (user) ->
      new Edit.DeactivateAccountForm
        model: user

    getLeftColumnLayoutView: ->
      new Edit.LeftColumnLayout

    getMiddleColumnLayoutView: ->
      new Edit.MiddleColumnLayout

    getUserInfoView: (user) ->
      new App.Shared.Views.Profile
        model: user

    getNavigationView: ->
      new Edit.Navigation

    getLayoutView: ->
      new Edit.Layout
