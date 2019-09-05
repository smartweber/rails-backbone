@Omega.module "HeaderApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.BaseNotification extends App.Views.ItemView
    tagName: 'li'

    behaviors:
      MarkSeen: {}

  class List.MessageNotification extends List.BaseNotification
    template: 'header/list/_message_notification'

  class List.CommonNotification extends List.BaseNotification
    getTemplate: ->
      'header/list/_common_'+@model.get('type')+'_notification'

  class List.StockNotification extends List.BaseNotification
    className: 'header-box-item chart-bottom'
    template: 'header/list/_stock_notification'

  class List.BaseNotifications extends App.Views.CompositeView
    childViewContainer: '.bb-items'
    className: ->
      name = ' btn-icon dropdown '
      name += @specificClassName
      name

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        items: @collection

    ui:
      badge: ".badge"
      dropdownMenu: '.dropdown-menu'
      headerIcon: '.header-icon'
      seeMoreLink: '.bb-see-more-link'
      noContentDropdownMessage: '.bb-no-content-dropdown'
      notificationsList: '.bb-items'

    collectionEvents:
      'add remove reset' : 'updateCounter'

    events:
      'click' : 'showDropdown'

    specificClassName: ->
      throw new Error "implement #specificClassName in your subclass returning class name string"

    showDropdown: (event) ->
      if @ui.dropdownMenu.hasClass('opened')
        @ui.dropdownMenu.removeClass('opened')
      else if @collection.length != 0
        @closeAllDropdownMenus()
        @ui.dropdownMenu.addClass('opened')

    showEmptyContents: ->
      @ui.seeMoreLink.hide()
      @ui.noContentDropdownMessage.show()
      @ui.notificationsList.hide()

    hideEmptyContents: ->
      @ui.noContentDropdownMessage.hide()
      @ui.seeMoreLink.show()
      @ui.notificationsList.show()

    closeAllDropdownMenus: ->
      $('.dropdown-menu').each ->
        $(@).removeClass('opened')

    updateCounter: ->
      if @collection.length <= 0
        @showEmptyContents()
        @ui.badge.hide()
        @ui.headerIcon.removeClass('opened')
      else
        @hideEmptyContents()
        @ui.badge.show()
        @ui.headerIcon.addClass('opened')
      @ui.badge.html(@collection.length)

    onAddChild: ->
      # If all childrens are rendered
      if @children.length == @collection.length
        @updateCounter()

    onRender: ->
      @updateCounter()

    initialize: ->
      @listenTo @, 'childview:notification:link:clicked', (child, args) ->
        @triggerMethod 'region:notification:link:clicked', child, args

  class List.MessageNotifications extends List.BaseNotifications
    childView: List.MessageNotification
    template: 'header/list/_message_notifications'
    specificClassName: 'dropdown-msgs'

    triggers:
      'click .bb-see-more-link' : 'see:more:link:clicked'

  class List.CommonNotifications extends List.BaseNotifications
    childView: List.CommonNotification
    template: 'header/list/_common_notifications'
    specificClassName: 'dropdown-alerts'

  class List.StockNotifications extends List.BaseNotifications
    childView: List.StockNotification
    template: 'header/list/_stock_notifications'
    specificClassName: 'dropdown-stock'

  class List.ProfileMenu extends App.Views.ItemView
    template: 'header/list/_profile_menu'
    tagName:'div'
    className:'dropdown dropdown-profile'

    ui:
      logoutLink:   '.bb-logout-link'
      messagesLink: '.bb-messages-link'
      settingsLink: '.bb-settings-link'

    triggers:
      'click @ui.logoutLink'   : 'signout:link:clicked'
      'click @ui.messagesLink' : 'messages:link:clicked'
      'click @ui.settingsLink' : 'settings:link:clicked'

    modelEvents:
      'change' : 'renderUnlessNew'

    renderUnlessNew: ->
      unless @model.isNew()
        @render()

  class List.NewUserLogin extends App.Views.ItemView
    template: 'header/list/_new_user_login'
    className: 'navbar-right form-inline form-login'

    ui:
      signupButton: '.bb-signup-btn'

    triggers:
      'click @ui.signupButton' : 'signup:button:clicked'

  class List.UnsignedUserForm extends App.Views.ItemView
    template: 'header/list/_unsigned_user_form'

    ui:
      signupButton: '.bb-signup-btn'
      loginButton: '.bb-login-btn'

    triggers:
      'click @ui.signupButton' : 'signup:button:clicked'
      'click @ui.loginButton'  : 'login:button:clicked'

    form:
      viewAttributes:
        className: 'navbar-right form-inline form-login'
        attributes:
          role: 'search'

  class List.FlashMessage extends App.Views.ItemView
    template: 'header/list/_flash_message'
    className: 'flash-message-item'

    triggers:
      'click' : 'flash:message:clicked'

  class List.FlashMessages extends App.Views.CollectionView
    childView: List.FlashMessage
    emptyView: App.Shared.Views.Empty
    className: 'flash-messages-container'

  class List.ModalView extends App.Views.ItemView
    template: 'header/list/_modal_loggedout'
    tagName: 'div'
    className: ''

    ui:
      modalEl: '#loggedOutModal'

    onBeforeRender: ->
      window.onclick     = @resetPresenceTimeout.bind @
      window.onkeypress  = @resetPresenceTimeout.bind @
      window.onscroll    = @resetPresenceTimeout.bind @
      window.onmousedown = @resetPresenceTimeout.bind @
      @resetPresenceTimeout()

    resetPresenceTimeout: ->
      clearTimeout(@presenceTimeout)
      @presenceTimeout = setTimeout(
        () =>
          @showModal()
      , 1000 * 60 * 10)

    restartVisibilityTimeout: ->
      @clearVisibilityTimeout()
      @visibilityTimeout = setTimeout(
        () =>
          @showModal()
      , 1000 * 60 * 5)

    clearVisibilityTimeout: ->
      clearTimeout(@visibilityTimeout)

    showModal: ->
      @triggerMethod "modal:displayed"
      @ui.modalEl.modal('show').on('hidden.bs.modal', () =>
        @triggerMethod "reload:page"
      )

  class List.Header extends App.Views.Layout
    template: 'header/list/header'
    tagName: 'header'
    className: 'navbar navbar-default sh-header navbar-fixed-top'

    triggers:
      'click .chats-route a'  : 'chats:link:clicked'
      'click .navbar-brand'   : 'logo:link:clicked'

    modelEvents:
      'change:id' : 'render'

    regions:
      messageRegion: '.message-region'
      commonRegion: '.common-region'
      stockRegion: '.stock-region'
      profileMenuRegion: '.profile-menu-region'
      newUserUIRegion: '.new-user-ui-region'
      flashMessageRegion: '.flash-message-region'
      modalRegion: '.modal-region'

    ui:
      typeaheadElement: '.typeahead'

    behaviors:
      Autocomplete:
        sources: ['users', 'companies']
        target: 'header'
        onSelect: (event, suggestion, dataset) ->
          App.navigate suggestion.target_url, trigger: true
          window.scroll(0,0)

    childEvents:
      'region:notification:link:clicked': (regionView, child, args) ->
        @triggerMethod 'region:notification:link:clicked', regionView, child, args

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        atSpecialPage: ->
          specialPaths = [Routes.new_user_session_path(), Routes.signup_path(), Routes.new_user_password_path()]
          not _.every specialPaths, (path) ->
            mainPathFragment = path.split('/')[1]
            _.isEmpty(Backbone.history.fragment.match(mainPathFragment))
