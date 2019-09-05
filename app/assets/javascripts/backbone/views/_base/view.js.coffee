@Omega.module "Views", (Views, App, Backbone, Marionette, $, _) ->

  _remove = Marionette.View::remove

  _.extend Marionette.View::,

    addOpacityWrapper: (init = true) ->
      @$el.toggleWrapper
        className: "opacity"
      , init

    setInstancePropertiesFor: (args...) ->
      for key, val of _.pick(@options, args...)
        @[key] = val

    remove: (args...) ->
      # console.log "removing", @
      if @model?.isDestroyed?()

        wrapper = @$el.toggleWrapper
          className: "opacity"
          backgroundColor: "red"

        wrapper.fadeOut 400, ->
          $(@).remove()

        @$el.fadeOut 400, =>
          _remove.apply @, args
      else
        _remove.apply @, args

    templateHelpers: ->

      currentUser: ->
        do (App) ->
          App.request 'get:current:user'

      linkTo: (content, url, options = {}) ->
        _.defaults options,
          escape: true

        content = @escape(content) if options.escape
        htmlClass = if options.htmlClass then " class='#{options.htmlClass}'" else ""
        "<a href='#{url}'#{htmlClass}>#{content}</a>"

      gravatarImageFor: (user, options = {}) ->
        # TODO:
        htmlClass = if options.htmlClass then " class='#{options.htmlClass}'" else ""
        alt = if options.alt then " alt='#{options.alt}'" else ""
        unless (user instanceof Backbone.Model)
          "<img src='#{user.gravatar_url}'#{htmlClass} alt='#{user.name}'>"
        else
          "<img src='#{user.get('gravatar_url')}'#{htmlClass}#{alt} alt='#{user.get('name')}'>"

      datetimeToHumanFormat: (datetime) ->
        moment(datetime).format('h:mmA MMM Do YYYY')

      datetimeToHumanFormatOT: (datetime) ->
        moment(datetime).format('h:mm A')

      datetimeToSimpleFormat: (datetime) ->
        moment(datetime).format('MMM D h:mm')

      datetimeToArticleFormat: (datetime) ->
        moment(datetime).format('dddd MMMM D, YYYY')

      popularityLinkFor: (likeable) ->
        if likeable.like.id?
          "<a class='bb-unlike-link' href='#'>Unlike</a>"
        else
          "<a class='bb-like-link' href='#'>Like</a>"

      saveButton: ->
        "<a href='#' class='add-to-favorites'>#{ if @favorited then 'Unsave' else 'Save' }</a>"

      timestampFor: (datetime) ->
        # If more than 30 days have passed
        if moment().subtract(30, 'days') > moment(datetime)
          "<time class='timeago timestamp' datetime='#{ datetime }' title='#{ moment(datetime).format('MMM Do YYYY h:mmA') }' >
            #{ moment(datetime).format('MMM Do YYYY') }
          </time>"
        else
          "<time class='timeago timestamp' datetime='#{datetime}'>
            #{ moment(datetime).format('MMM Do YYYY h:mmA') }
          </time>"

      followButton: (buttonStyle) ->
        switch buttonStyle
          when 'companyProfile'
            "<a href='#' class='btn btn-lg btn-primary bb-follow-btn'><i class='icon-chevron-right'></i><i class='icon-chevron-right'></i> Track</a>"
          when 'recommendations'
            "<a href='#' class='btn btn-lg btn-primary bb-follow-company-btn'><i class='icon-chevron-right'></i><i class='icon-chevron-right'></i> Track</a>"
          when 'userProfile'
            "<a href='#' class='btn btn-primary bb-follow-user'><i class='icon-chevron-right'></i><i class='icon-chevron-right'></i> Follow</a>"

      unfollowButton: (buttonStyle) ->
        switch buttonStyle
          when 'companyProfile'
            "<a href='#' class='btn btn-lg btn-primary btn-following bb-unfollow-btn'><span class='following-txt'><i class='icon-chevron-right'></i><i class='icon-chevron-right'></i> Tracking</span><span class='unfollow-txt'><i class='icon-close'></i> Untrack</span></a>"
          when 'recommendations'
            "<a href='#' class='btn btn-lg btn-primary btn-following bb-unfollow-company-btn'><span class='following-txt'><i class='icon-chevron-right'></i><i class='icon-chevron-right'></i> Tracking</span><span class='unfollow-txt'><i class='icon-close'></i> Untrack</span></a>"
          when 'userProfile'
            "<a href='#' class='btn btn-primary btn-following bb-follow-user'><span class='following-txt'><i class='icon-chevron-right'></i><i class='icon-chevron-right'></i> Following</span><span class='unfollow-txt'><i class='icon-close'></i> Unfollow</span></a>"

      followingButton: (followable, buttonStyle) ->
        followableFollowed = if followable instanceof Backbone.Model
          followable.get('relationship').isNew()
        else
          followable.relationship.id?
        if (followableFollowed) then @unfollowButton(buttonStyle) else @followButton(buttonStyle)

      notificationIcons: ->
        for glyphiconClass in ['user', 'comment', 'bullhorn', 'signal']
          @notificationButtonFor glyphiconClass

      closeIcon: ->
        "<a href='#' class='mark-read'><span aria-hidden='true'>x</span></a>"

      currentUserCan: (action, resource) ->
        App.currentUser?.can(action, resource)

      badgeFor: (collection) ->
        if collection.length == 0
          "<span class='badge' style='display:none'>#{ collection.length }</span>"
        else
          "<span class='badge'>#{ collection.length }</span>"

      messageDeliveryBadgeWithStatus: (isSeen) ->
        if isSeen
          "<span class='icon icon-reply seen'></span>"
        else
          "<span class='icon icon-reply'></span>"

      commentsCounter: ->
        if @comments_count > 0
          "<a href='#'><span class='icon-comments'></span> #{ @comments_count }</a>"

      likesCounter: ->
        if @likes_count > 0
          "<a href='#'><span class='icon-thumbs-o-up'></span> #{ @likes_count }</a>"

      agnosticAssetPath: (filename) ->
        asset_path(filename + '.jpg') or asset_path(filename + '.png')

      currentPercentageForRange: (low, high, current) ->
        if high != null and low != null and current != null
          movingRange   = high - low
          distanceToTop = high - current
          Math.round(distanceToTop/movingRange * 100)
        else
          "n/a"

      week52rangePercentage: (quote) ->
        @currentPercentageForRange(quote.pricedata.low, quote.pricedata.high, quote.pricedata.last)

      rangePercentage: (quote) ->
        @currentPercentageForRange(quote.fundamental.week52low.content, quote.fundamental.week52high.content, quote.pricedata.last)

      stockChange: (quote, {coefficient = 1, widget = ''} = {}) ->
        rChange        = Math.round10(quote.pricedata.change * coefficient, -2)
        rChangepercent = Math.round10(quote.pricedata.changepercent, -2)
        colorClassName = if rChange > 0
          'up'
        else if rChange < 0
          'down'
        else
          'no-changes'
        stockChangeStr = unless typeof quote.pricedata.change == "number" or typeof quote.pricedata.changepercent == "number"
          "N/A"
        else if rChangepercent == 0 or rChange == 0
          "N/C"
        else if widget == 'marketSnapshot'
          " (#{ rChangepercent.toFixed(2) }%)"
        else
          "#{ rChange.toFixed(2) }(#{ rChangepercent.toFixed(2) }%)"
        "<div class='change-rate #{colorClassName}'>
          <span>#{ stockChangeStr }</span>
        </div>"

      dividentFor: (quote) ->
        if typeof quote.fundamental.dividend?.amount == "number" and typeof quote.fundamental.dividend?.yield == "number"
          "#{quote.fundamental.dividend.amount.toFixed(2)} / #{quote.fundamental.dividend.yield.toFixed(2)}%"
        else
          "-"

      lastPrice: (quote, coefficient=1) ->
        if typeof quote.pricedata?.last == "number"
          Math.round10(quote.pricedata.last * coefficient, -2)
        else
          'n/a'

      lastPriceFor: (quote, options={}) ->
        options.coefficient = 1 if options.coefficient == undefined
        options.withChevron = true if options.withChevron == undefined
        options.commaSeparation = true if options.commaSeparation == undefined

        lastPrice = @lastPrice(quote, options.coefficient)
        if typeof lastPrice == "number"
          lastPrice = if options.commaSeparation then lastPrice.formatMoney(2) else lastPrice.toFixed(2)
          if options.withChevron
            lastPrice = "#{ lastPrice }<span class='symbol icon-chevron-circle-#{ if quote.pricedata.change > 0 then 'up' else 'down' }'></span>"
        lastPrice

      tileLastPriceFor: (quote) ->
        "<i class='icon-chevron-circle-#{ if quote.pricedata?.change > 0 then 'up' else 'down' }'></i> <span>#{ @lastPrice(quote) }</span>"

      essentialDataFor: (quote, options={}) ->
        "<div class='pull-right trade #{ if quote.pricedata?.change > 0 then 'up' else 'down' }'>
          <strong>#{ @lastPriceFor(quote, options) }</strong>
          <span> #{ @stockChange(quote, options) }</span>
        </div>"

      abbrWithExchange: ->
        s(@exchange).toUpperCase().value() + ':' + s(@abbr).toUpperCase().value()

      lastTradeTimeFor: (quote) ->
        unless typeof quote.pricedata.lasttradedatetime == "undefined"
          "N/A"
        else
          @marketStatusPrefix(quote) + moment.parseZone(quote.pricedata.lasttradedatetime).format("h:mm:ss A") + " EST"

      marketStatusPrefix: (quote) ->
        #########################################
        # Premarket 6:30am - 9:30am
        # Delayed: 9:30am - 4pm
        # After Hours: 4pm - 9pm
        # Closed: 9pm - 6:30am and weekends
        ##############################################

        parsedLastTradeDateTime = moment.parseZone(quote.pricedata.lasttradedatetime, moment.ISO_8601)
        sameDay = quote.pricedata.lasttradedatetime.split('T')[0];
        startOfDay = moment.parseZone(sameDay + 'T06:30:00-05:00')
        stockOpen = moment.parseZone(sameDay + 'T09:30:00-05:00')
        stockClose = moment.parseZone(sameDay + 'T16:00:00-05:00')
        endOfDay = moment.parseZone(sameDay + 'T21:00:00-05:00')

        if parsedLastTradeDateTime.day() > 5
          'Closed: '
        else if parsedLastTradeDateTime.isBetween(startOfDay, stockOpen)
          "Premarket: "
        else if parsedLastTradeDateTime.isBetween(stockOpen, stockClose)
          "Delayed: "
        else if parsedLastTradeDateTime.isBetween(stockClose, endOfDay)
          "After hours: "
        else
          'Closed: '

      prevCloseFor: (quote) ->
        prevclose = quote.pricedata.prevclose
        if typeof prevclose == "number" then prevclose.toFixed(2) else prevclose

      lowFor: (quote) ->
        low = quote.pricedata.low
        if typeof low == "number" then low.toFixed(2) else low

      highFor: (quote) ->
        high = quote.pricedata.high
        if typeof high == "number" then high.toFixed(2) else high

      openFor: (quote) ->
        open = quote.pricedata.open
        if typeof open == "number" then open.toFixed(2) else open

      week52lowFor: (quote) ->
        week52low = quote.fundamental.week52low.content
        if typeof week52low == "number" then week52low.toFixed(2) else week52low

      week52highFor: (quote) ->
        week52high = quote.fundamental.week52high.content
        if typeof week52high == "number" then week52high.toFixed(2) else week52high

      shareVolumeFor: (quote) ->
        if typeof quote.pricedata.sharevolume == "number"
          "#{Math.round10((quote.pricedata.sharevolume / 1000000), -2)}M"
        else
          'n/a'

      bidFor: (quote) ->
        if typeof quote.pricedata.bid == "number" and typeof quote.pricedata.bidsize == "number"
          "#{quote.pricedata.bid.toFixed(2)} x #{quote.pricedata.bidsize}"
        else
          'n/a'

      askFor: (quote) ->
        if typeof quote.pricedata.ask == "number" and typeof quote.pricedata.asksize == "number"
          "#{quote.pricedata.ask.toFixed(2)} x #{quote.pricedata.asksize}"
        else
          'n/a'

      marketcapFor: (quote) ->
        if typeof quote.fundamental.marketcap == "number"
          "#{Math.round10((quote.fundamental.marketcap / 1000000000), -2)}B"
        else
          'n/a'

      peratioFor: (quote) ->
        peratio = quote.fundamental.peratio
        if typeof peratio == "number" then peratio.toFixed(2) else peratio

      epsFor: (quote) ->
        eps = quote.fundamental.eps
        if typeof eps == "number" then eps.toFixed(2) else eps

      sharesoutstandingFor: (quote) ->
        if typeof quote.fundamental.sharesoutstanding == "number"
          "#{Math.round10((quote.fundamental.sharesoutstanding / 1000000000), -2)}B"
        else
          'n/a'

      pbratioFor: (quote) ->
        pbratio = quote.fundamental.pbratio
        if typeof pbratio == "number" then pbratio.toFixed(2) else pbratio

      # TODO: should probably be in backbone view instead
      rangeIndicatorFor: (quote, lowFunc, highFunc, percentage, title) ->
        "<div class='detail'>
          <span class='detail-title'>#{ title }</span>
          <div class='progress-indicators'>
            <div class='progress-numbers clearfix'>
              <span class='lower pull-left'>#{ lowFunc(quote) }</span>
              <span class='higher pull-right'>#{ highFunc(quote) }</span>
            </div>
            <div class='progress'>
              <div class='progress-bar' role='progressbar' aria-valuenow='#{ percentage }' aria-valuemin='0' aria-valuemax='100' style='width: #{ percentage }%;'>
                <span class='sr-only'>#{ percentage }% Complete</span>
              </div>
            </div>
            <i class='progress-pointer symbol icon-angle-up' style='left: #{ percentage }%'></i>
          </div>
        </div>"

      tile: (quote) ->
        imageName = if quote.pricedata.change > 0 then 'command-stat-green.png' else 'command-stat-red.png'
        "<div class='company-stats'>
          <div class='bb-change'></div>
          <img src='#{ asset_path(imageName) }' class='img-responsive' />
        </div>"

      tileStockChange: (quote) ->
        rChange        = Math.round10(quote.pricedata.change, -2)
        rChangepercent = Math.round10(quote.pricedata.changepercent, -2)
        stockIsRising = quote.pricedata.change > 0
        schevronClass = if stockIsRising then "icon-chevron-up" else "icon-chevron-down"
        "<div class='tile-change #{ if stockIsRising then 'up' else 'down' }'>
          <span class='#{ schevronClass }'></span><strong> #{ Math.abs(rChange.toFixed(2)) }</strong>
          <br>
          <span>&nbsp; #{ Math.abs(rChangepercent.toFixed(2)) }%</span>
        </div>"
