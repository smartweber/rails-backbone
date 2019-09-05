@Omega.module "UserApp.Edit", (Edit, App, Backbone, Marionette, $, _) ->

  class Edit.Layout extends App.Views.Layout
    template: 'user/edit/layout'

    regions:
      leftColumnRegion: '#left-column-region'
      middleColumnRegion: '#middle-column-region'
      rightColumnRegion: '#right-column-region'

  class Edit.LeftColumnLayout extends App.Views.Layout
    template: 'user/edit/_left_column_layout'
    className: 'col-lg-5 col-md-6'

    regions:
      userInfoRegion: '#user-info-region'
      navigationRegion: '#navigation-region'

  class Edit.MiddleColumnLayout extends App.Views.Layout
    template: 'user/edit/_middle_column_layout'
    className: 'col-lg-14 col-md-12'

    regions:
      generalTabRegion: '#general-tab-region'
      securityTabRegion: '#security-tab-region'
      blockedAccountsTabRegion: '#blocked-accounts-tab-region'
      notificationsTabRegion: '#notifications-tab-region'

  class Edit.RightColumnLayout extends App.Views.Layout
    template: 'user/edit/_right_column_layout'
    className: 'col-lg-5 col-md-6'

    regions:
      marketSnapshotRegion: '#market-snapshot-region'
      marketHeadlinesRegion: '#market-headlines-region'
      userRecommendationsRegion: '#user-recommendations-region'
      sidebarFooterRegion: '#sidebar-footer-region'

  class Edit.GeneralTabLayout extends App.Views.Layout
    template: 'user/edit/_general_tab_layout'
    className: 'panel panel-default sh-panel'

    regions:
      generalSettingsFormRegion: '#general-settings-form-region'
      accountDeactivationFormRegion: '#account-deactivation-form-region'

  class Edit.SecurityTabLayout extends App.Views.Layout
    template: 'user/edit/_security_tab_layout'
    className: 'panel panel-default sh-panel'

    regions:
      securitySettingsFormRegion: '#security-settings-form-region'

  class Edit.BlockedAccountsTab extends App.Views.ItemView
    template: 'user/edit/_blocked_accounts_tab'
    className: 'panel panel-default sh-panel'

  class Edit.NotificationsTab extends App.Views.ItemView
    template: 'user/edit/_notifications_tab'
    className: 'panel panel-default sh-panel'

  class Edit.SecuritySettingsForm extends App.Shared.Views.Form
    template: 'user/edit/_security_settings_form'
    modelClassName: 'User'
    inputFields: ->
      []

    form:
      viewAttributes:
        className: 'form-horizontal'

  class Edit.GeneralSettingsForm extends App.Shared.Views.Form
    template: 'user/edit/_general_settings_form'
    modelClassName: 'User'
    inputFields: ->
      []

    form:
      viewAttributes:
        className: 'form-horizontal'

  class Edit.DeactivateAccountForm extends App.Shared.Views.Form
    template: 'user/edit/_account_deactivation_form'
    modelClassName: 'User'
    inputFields: ->
      []

    viewAttributes:
      className: 'form-horizontal'

  class Edit.Navigation extends App.Views.ItemView
    template: 'user/edit/_navigation'
    tagName: 'ul'
    className: 'nav nav-stacked user-profile-page-tabs'
    attributes:
      role: 'tablist'
