@Omega.module 'Extensions', (Extensions, App, Backbone, Marionette, $, _) ->
  # TODO: rename 'Extensions' to 'Shared.Extensions'(to follow one style with other shared modules)
  class Extensions.BackgroundResize extends Marionette.Object
    initialize: ->
      @theWindow = $(window)
      @$bg = $("#signup-bg")
      @aspectRatio = 1600 / 900
      @theWindow.resize(=>
        @resizeBg()
      ).trigger "resize"

    resizeBg: ->
      if (@theWindow.width() / @theWindow.height()) < @aspectRatio
        @$bg.removeClass().addClass "bgheight"
      else
        @$bg.removeClass().addClass "bgwidth"

  Extensions.LiveUpdates =
    subscribeToLiveUpdates: (companies) ->
      App.execute "websocket:companies:live_update:subscribe", companies
      _.each companies, (company) ->
        App.vent.on "company:quote:update:received:#{company.get('abbr')}", (quote) ->
          company.set quote: JSON.parse(quote)

    unsubscribeFromLiveUpdates: ->
      App.execute "websocket:companies:live_update:unsubscribe:all"

  Extensions.Likeable =
    like: ->
      like = @get('like')
      like.save null,
        success: =>
          @set likes_count: @get('likes_count') + 1

    unlike: ->
      like = @get('like')
      like.destroy success: (model, response) =>
        like = App.request "new:like:entity", @
        @set
          like: like
          likes_count: @get('likes_count') - 1
