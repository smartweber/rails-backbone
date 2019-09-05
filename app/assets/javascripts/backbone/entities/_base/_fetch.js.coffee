@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  App.commands.setHandler "when:fetched", (entities, callback, error) ->
    xhrs = if entities?
      _.chain([entities]).flatten().pluck("_fetch").value()
    else
      new Array

    $.when(xhrs...).done ->
      callback()

    if error
      $.when(xhrs...).fail ->
        error()
