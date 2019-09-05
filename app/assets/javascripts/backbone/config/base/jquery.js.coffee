do ($) ->
  $.fn.toggleWrapper = (obj = {}, init = true) ->
    _.defaults obj,
      className: ""
      backgroundColor: if @css("backgroundColor") isnt "transparent" then @css("backgroundColor") else "white"
      zIndex: if @css("zIndex") is "auto" or 0 then 1000 else (Number) @css("zIndex")

    $offset = @offset()
    $width  = @outerWidth(false)
    $height = @outerHeight(false)

    if init
      $("<div>")
        .appendTo("body")
          .addClass(obj.className)
            .attr("data-wrapper", true)
              .css
                width: $width
                height: $height
                top: $offset.top
                left: $offset.left
                position: "absolute"
                zIndex: obj.zIndex + 1
                backgroundColor: obj.backgroundColor
    else
      $("[data-wrapper]").remove()

  $.timeago.settings.strings =
    prefixAgo: null
    prefixFromNow: null
    suffixAgo: 'ago'
    suffixFromNow: 'from now'
    seconds: 'less than a minute'
    minute: '%dm'
    minutes: '%dm'
    hour: '%dhr'
    hours: '%dhr'
    day: 'a day'
    days: '%dd'
    month: 'about a month'
    months: '%d months'
    year: 'about a year'
    years: '%d years'
    wordSeparator: ' '
    numbers: []
  # Month in milliseconds
  $.timeago.settings.cutoff = 30*24*60*60*1000

  $(document).ajaxSend( (ev, xhr, options) ->
    if !options.noCSRF
      token = window.Omega.csrfToken
      if token
        xhr.setRequestHeader 'X-CSRF-Token', token
      # this will include session information in the requests
      xhr.withCredentials = true
      return
  )
