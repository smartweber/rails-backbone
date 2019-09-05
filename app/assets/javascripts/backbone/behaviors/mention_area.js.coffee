@Omega.module "Behaviors", (Behaviors, App, Backbone, Marionette, $, _) ->

  class Behaviors.MentionArea extends Marionette.Behavior
    # TODO: move bloodhound into own behavior
    initialize: ->
      @bloodhoundUsers     = @getBloodhoundUsers()
      @bloodhoundCompanies = @getBloodhoundCompanies()

    defaults:
      "displayTriggerChar": true
      "triggerChar": ['@', '$']

    getBloodhoundUsers: ->
      users = new Bloodhound(
        name: 'users'
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace("user")
        queryTokenizer: Bloodhound.tokenizers.nonword
        remote:
          url: Routes.api_users_path() + '?query=%QUERY'
      )
      users.initialize()
      users

    getBloodhoundCompanies: ->
      companies = new Bloodhound(
        name: 'companies'
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace("company")
        queryTokenizer: Bloodhound.tokenizers.nonword
        remote:
          url: Routes.api_companies_path() + '?query=%QUERY'
      )
      companies.initialize()
      companies

    onRender: ->
      @ui.mentionElement.mentionsInput
        elastic: false
        triggerChar: @options.triggerChar
        minChars: 1
        displayTriggerChar: @options.displayTriggerChar
        templates:
          wrapper                    : _.template('<div class="mentions-input-box"></div>'),
          autocompleteList           : _.template('<div class="mentions-autocomplete-list"></div>'),
          autocompleteListItem       : _.template('<li data-ref-id="<%= id %>" data-ref-type="<%= type %>" data-display="<%= display %>"><%= content %></li>'),
          autocompleteListItemAvatar : _.template('<img src="<%= avatar %>" />'),
          autocompleteListItemIcon   : _.template('<div class="icon <%= icon %>"></div>'),
          mentionsOverlay            : _.template('<div class="mentions" style="display:none"><div></div></div>'),
          mentionItemSyntax          : _.template('<%= triggerChar %>[<%= value %>](<%= type %>:<%= id %>)'),
          mentionItemHighlight       : _.template('<strong><span><%= value %></span></strong>')
        onDataRequest: (mode, query, callback, triggerChar) =>
          route = switch triggerChar
            when '@'
              @bloodhoundUsers.get query, (suggestions) ->
                callback.call @, suggestions, 'username'
            when '$'
              @bloodhoundCompanies.get query, (suggestions) ->
                callback.call @, suggestions, 'abbr'
