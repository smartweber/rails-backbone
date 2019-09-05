@Omega.module "Shared.Views", (Views, App, Backbone, Marionette, $, _) ->

  class Views.Empty extends App.Views.ItemView
    template: 'shared/shared/_empty'

  class Views.NewPreloadedAttachment extends App.Views.ItemView
    getTemplate: ->
      if @model.get('type_of_attachment') == 'link'
        "shared/attachments/_new_link_attachment"
      else
        "shared/attachments/_new_image_attachment"

    events:
      'click .bb-remove' : 'onAttachmentDeleteButtonClicked'

    onAttachmentDeleteButtonClicked: ->
      @model.destroy()

  class Views.Attachment extends App.Views.ItemView
    getTemplate: ->
      if @model.get('type_of_attachment') == 'link'
        "shared/attachments/_link_attachment"
      else
        "shared/attachments/_image_attachment"

    events:
      'click .bb-remove' : 'onAttachmentDeleteButtonClicked'

    onAttachmentDeleteButtonClicked: ->
      @model.destroy()

  class Views.ImageFileAttachment extends App.Views.ItemView
    template: 'shared/shared/_image_upload_preview'
    className: 'attachment'

    ui:
      previewImage: '.bb-preview-image'
      hiddenFileInput: '.bb-hidden-file-input'

    events:
      'change @ui.hiddenFileInput' : 'onFileAttached'
      'click .bb-remove' : 'onAttachmentDeleteButtonClicked'

    onFileAttached: (onChangeEvent) ->
      reader = new FileReader
      reader.onload = (onLoadEvent) =>
        target = onChangeEvent.target
        base64Image = if /^image/.test(target.files[0].type) then onLoadEvent.target.result else 'image.png'
        title = target.files[0].name
        $(@ui.previewImage).attr('src', base64Image)
        $(@ui.previewImage).attr('title', title)
        $(@ui.hiddenFileInput).data('base64', base64Image)
        @$el.find('.upload:first').removeClass('hidden')

      reader.readAsDataURL(onChangeEvent.currentTarget.files[0])

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        namePrefix: =>
          if @model.multipartForm
            "#{@model.get('attachable_type')}[attachments]"
          else
            "attachments"

    onAttachmentDeleteButtonClicked: ->
      @model.destroy()

  class Views.Attachments extends App.Views.CollectionView
    childView: Views.Attachment

  class Views.NewAttachments extends App.Views.CollectionView
    getChildView: (model) ->
      # if attached file from filesystem
      if model.isNew() and model.isImage()
        Views.ImageFileAttachment
      else
        Views.NewPreloadedAttachment

  class Views.Profile extends App.Views.ItemView
    template: 'shared/user/_profile'
    className: 'well well-profile'

    modelEvents:
      'change' : 'renderUnlessNew'

    ui:
      sectionLink: '.bb-section-link'

    events:
      'click @ui.sectionLink' : 'onSectionLinkClicked'

    onSectionLinkClicked: (e) ->
      @trigger 'section:link:clicked', e

    renderUnlessNew: ->
      unless @model.isNew()
        @render()

  class Views.Form extends App.Views.Layout
    preValidate: true
    modelClassName: ->
      throw new Error 'implement #modelClassName in your FormView subclass to return a string'

    inputFields: ->
      throw new Error 'implement #inputFields in your FormView subclass to return an array of strings'

    updateModel: ->
      @model.set @modelAttributes()

    delegateEvents: (events) ->
      @ui = _.extend @_formUI(), _.result(this, 'ui')
      super events

    _formUI: ->
      _.object(@inputFields(), _.map(@inputFields(), @getFieldSelector))

    modelAttributes: ->
      _.object(@inputFields(), _.map(@inputFields(), @getFormInputValue))

    getFieldSelector: (name) =>
      "[name='#{@modelClassName.toLowerCase()}[#{name}]']"

    getFormInputValue: (name) =>
      @ui[name].val()

  class Views.UsersSuggestionsHeader extends App.Views.ItemView
    template: 'shared/autocomplete/users_suggestions_header'

  class Views.UserSuggestion extends App.Views.ItemView
    template: 'shared/autocomplete/_user_suggestion'

    events:
      'click .bb-follow-user' : 'onFollowButtonClicked'

    modelEvents:
      'change:followers_count' : 'render'

    onFollowButtonClicked: (e) ->
      e.preventDefault()
      e.stopPropagation()
      relationship = @model.get('relationship')
      currentUser  = App.request 'get:current:user'
      if relationship.isNew()
        relationship.save null,
          success: =>
            @model.set followers_count: @model.get('followers_count') + 1
            currentUser.set following_users_count: currentUser.get('following_users_count') + 1
      else
        relationship.destroy success: (model, response) =>
          newRelationship = App.request "new:relationship:entity", @model
          @model.set
            relationship: newRelationship
            followers_count: @model.get('followers_count') - 1
          currentUser.set following_users_count: currentUser.get('following_users_count') - 1

    initialize: ->
      relationship = App.request "new:relationship:entity", @model
      @model.set relationship: relationship

  class Views.CompaniesSuggestionsHeader extends App.Views.ItemView
    template: 'shared/autocomplete/companies_suggestions_header'

  class Views.CompanySuggestion extends App.Views.ItemView
    template: 'shared/autocomplete/_company_suggestion'

  class Views.TrendingStock extends App.Views.ItemView
    template: 'shared/trending_stocks/_trending_stock'
    tagName: 'li'
    className: 'list-group-item'

    triggers:
      'click a' : 'company:link:clicked'

    behaviors:
      LiveValues: {}

    ui:
      essentialData: '.bb-essential-data'

    bindings:
      '.bb-essential-data':
        observe: ['quote.pricedata.last', 'quote.pricedata.change', 'quote.pricedata.changepercent']
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.essentialData
        onGet: (value) ->
          @helpers.essentialDataFor(@model.get('quote'))

  class Views.TrendingStocks extends App.Views.CompositeView
    template: 'shared/trending_stocks/_trending_stocks'
    childView: Views.TrendingStock
    childViewContainer: '.bb-trending-stocks'
    tagName: 'ul'
    className: 'list-group list-well'

  class Views.MarketSnapshot extends App.Views.ItemView
    template: 'shared/market_snapshot/_market_snapshot'
    tagName: 'li'
    className: 'list-group-item'

    triggers:
      'click a' : 'company:link:clicked'

    behaviors:
      LiveValues: {}

    ui:
      essentialData: '.bb-essential-data'

    bindings:
      '.bb-essential-data':
        observe: ['quote.pricedata.last', 'quote.pricedata.change', 'quote.pricedata.changepercent']
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.essentialData
        onGet: (value) ->
          @helpers.essentialDataFor(@model.get('quote'), {
            coefficient: @getCoefficient()
            widget: 'marketSnapshot'
            withChevron: false
          })

    getCoefficient: ->
      @model.specialMapping[@model.get('abbr')].coefficient

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        simplifiedName: =>
          @model.specialMapping[@model.get('abbr')].simpleName

  class Views.MarketSnapshots extends App.Views.CompositeView
    template: 'shared/market_snapshot/_market_snapshots'
    childView: Views.MarketSnapshot
    childViewContainer: '.bb-market-snapshots-items'
    tagName: 'ul'
    className: 'list-group list-well'

  class Views.EmptyMarketHeadlines extends App.Views.ItemView
    template: 'shared/market_headlines/_empty_market_headlines'

  class Views.MarketHeadline extends App.Views.ItemView
    template: 'shared/market_headlines/_market_headline'

  class Views.MarketHeadlines extends App.Views.CompositeView
    template: 'shared/market_headlines/_market_headlines'
    emptyView: Views.EmptyMarketHeadlines
    childView: Views.MarketHeadline
    childViewContainer: '.bb-headlines'
    className: 'list-group list-well list-headlines'

    ui:
      nextLink: '.bb-next-page'
      prevLink: '.bb-prev-page'
      pageNumber: '.bb-page-number span'

    triggers:
      'click @ui.nextLink' : 'next:page:link:clicked'
      'click @ui.prevLink' : 'prev:page:link:clicked'

    collectionEvents:
      'reset' : 'changePageNumber'

    toggleLinks: ->
      @ui.prevLink.toggle()
      @ui.nextLink.toggle()

    changePageNumber: ->
      @ui.pageNumber.text(@collection.page)

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        pageNumber: @collection.page

  class Views.UserFollowRecommendations extends App.Views.ItemView
    template: 'shared/user_follow_recommendations/_user_follow_recommendations'
    tagName: 'ul'
    className: 'list-group list-well'

  class Views.NewPostForm extends App.Shared.Views.Form
    template: 'shared/shared/_new_post_form'
    className: 'panel panel-default sh-panel'
    modelClassName: 'post'

    ui:
      shareButton: '.btn-share'
      previews: '.bb-previews'
      textArea: 'textarea'
      mentionElement: '.bb-mention-element'

    triggers:
      'paste @ui.textArea' :
        event: 'new:post:body:paste'
        preventDefault: false
      'click @ui.shareButton' : 'wrapped:form:submit'

    events:
      'keyup @ui.textArea' : 'onTextAreaKeyup'

    behaviors:
      Pasteable: { eventName: "new:post:body:paste", attachableType: 'post' }
      Attachable: { attachableType: 'post' }
      MentionArea: {}

    regions:
      attachmentsRegion: '.attachments-region'

    inputFields: ->
      ['content']

    onTextAreaKeyup: ->
      $(@ui.shareButton).toggleClass('disabled', !@ui.textArea.val())

  class Views.CompanyChart extends App.Views.ItemView
    template: 'shared/company_chart/_company_chart'

    onRender: ->
      @insertChart(document, 'script', 'chart-widget')

    insertChart: (d, s, id) ->
      fjs      = d.getElementsByClassName('company-chart')[0]
      js       = d.createElement(s)
      js.id    = id
      js.defer = "defer"
      js.src   = "https://app.quotemedia.com/quotetools/getJsChart.go?webmasterId=102098&symbol=#{@model.get('abbr')}&chscale=1d&chhig=500&chwid=960&smartLookup=true&symbolLookup=true&chline=7698b7&rangeColor=aaaaaa&chxyc=000000&chgrd=dddddd"
      fjs.parentNode.insertBefore js, fjs

  # TODO: refactor
  class Views.Tile extends App.Views.ItemView
    template: 'shared/shared/_tile'
    className: ->
      @getClassName()

    behaviors:
      LiveValues: {}

    ui:
      lastPrice: '.bb-tile-last-price'
      change: '.bb-change'

    bindings:
      '.bb-tile-last-price':
        observe: 'quote.pricedata.last'
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.lastPrice
        onGet: (value) ->
          @helpers.tileLastPriceFor(@model.get('quote'))
      '.bb-change':
        observe: ['quote.pricedata.change', 'quote.pricedata.changepercent']
        update: ($el, val, model, options) ->
          @regularDataUpdateAnimationFor val, @ui.change
        onGet: (value) ->
          @helpers.tileStockChange(@model.get('quote'))

    triggers:
      'click' : 'company:chart:clicked'
      'mouseenter' : 'hover:company:tile:triggered'

    templateHelpers: ->
      _.extend Marionette.View.prototype.templateHelpers(),
        logoPresent: =>
          if asset_path("squared-logos/#{@model.normalizedAbbr()}.png") then true else false
        logoPath: =>
          asset_path("squared-logos/#{@model.normalizedAbbr()}.png")

    getClassName: ->
      name = 'company-item value-up '
      name += if asset_path("squared-logos/#{@model.normalizedAbbr()}.png") then 'with-logo' else 'no-logo'
      name

  class Views.Tiles extends App.Views.CollectionView
    childView: Views.Tile
    className: 'bb-trending-tiles'

  class Views.NewUserPostFormReplacement extends App.Views.ItemView
    template: 'shared/shared/_new_user_post_form_replacement'
    className: 'panel panel-default sh-panel'

    ui:
      loginBtn: '.bb-login-btn'
      signupBtn: '.bb-signup-btn'

    triggers:
      'click @ui.loginBtn' : 'login:button:clicked'
      'click @ui.signupBtn' : 'signup:button:clicked'
