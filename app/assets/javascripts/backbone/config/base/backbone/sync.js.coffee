do (Backbone) ->
  _sync = Backbone.sync
  window.Omega = window.Omega || {}
  Backbone.sync = (method, entity, options = {}) ->

    _.defaults options,
      beforeSend: _.bind(methods.beforeSend,  entity)
      complete:   _.bind(methods.complete,    entity)

    if !options.noCSRF
      beforeSend = options.beforeSend
      # Set X-CSRF-Token HTTP header
      # TODO: remove that in favour of jquery.js.coffee's ajaxSend
      options.beforeSend = (xhr) ->
        token = window.Omega.csrfToken
        if token
          xhr.setRequestHeader 'X-CSRF-Token', token
        # this will include session information in the requests
        xhr.withCredentials = true
        if beforeSend
          return beforeSend.apply(this, arguments)
        return

    complete = options.complete
    options.complete = (jqXHR, textStatus) ->
      # If response includes CSRF token we need to remember it
      token = jqXHR.getResponseHeader('X-CSRF-Token')
      if token
        window.Omega.csrfToken = token
        $('meta[name=csrf-token]').attr('content', token)
      entity.trigger 'sync:end', entity, jqXHR, textStatus
      if complete
        complete jqXHR, textStatus
      return

    # Serialize data, optionally using paramRoot
    if not options.data? and entity and (method is "create" or method is "update" or method is "patch")
      options.contentType = "application/json"
      data = {}
      if entity.paramRoot and method != "patch"
        data[entity.paramRoot] = entity.toJSON(options)
        options.data = JSON.stringify(data)
      else if entity.paramRoot and method is "patch"
        data[entity.paramRoot] = options.attrs
        options.data = JSON.stringify(data)
      else
        options.data = JSON.stringify(options.attrs or entity.toJSON(options))

    sync = _sync(method, entity, options)
    if !entity._fetch and method is "read"
      entity._fetch = sync

    return sync

  methods =
    beforeSend: ->
      @trigger "sync:start", @

    complete: ->
      @trigger "sync:stop", @
