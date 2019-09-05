@Omega.module "Behaviors", (Behaviors, App, Backbone, Marionette, $, _) ->

  class Behaviors.BloodhoundMethods extends Marionette.Behavior
    initialize: ->
      @bloodhoundUsers     = @getBloodhoundUsers()
      @bloodhoundCompanies = @getBloodhoundCompanies()

    getBloodhoundUsers: ->
      users = new Bloodhound(
        name: 'users'
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace("user")
        queryTokenizer: Bloodhound.tokenizers.nonword
        limit: 5
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
        limit: 5
        remote:
          url: Routes.api_companies_path() + '?query=%QUERY'
      )
      companies.initialize()
      companies

  class Behaviors.Autocomplete extends Behaviors.BloodhoundMethods
    initialize: ->
      super
      @typeaheadConfigs = [
        {
          name: 'users',
          displayKey: 'username',
          templates: {
            suggestion: (user) ->
              new App.Shared.Views.UserSuggestion({model: new App.Entities.User(user)}).render().$el
            header: ->
              new App.Shared.Views.UsersSuggestionsHeader().render().$el
          },
          source: @bloodhoundUsers.ttAdapter()
        },
        {
          name: 'companies',
          displayKey: ['abbr', 'name'],
          templates: {
            suggestion: (company) ->
              new App.Shared.Views.CompanySuggestion({model: new App.Entities.Company(company)}).render().$el
            header: ->
              new App.Shared.Views.CompaniesSuggestionsHeader().render().$el
          },
          source: @bloodhoundCompanies.ttAdapter()
          options: @bloodhoundCompanies
        }
      ]

    onRender: ->
      @initializeAutocomplete()

    initializeAutocomplete: ->
      if @options.target && @options.target is 'header' && !@view.model.id
        @options.sources = ['companies']
        loggedOff = true
      requestedSources = _.flatten([@options.sources])
      sources = @typeaheadConfigs.filter (obj) =>
        if obj.options && loggedOff
          obj.options.limit = 10
        requestedSources.indexOf(obj.name) >= 0
      @ui.typeaheadElement.typeahead {highlight: true}, sources
      if typeof(@options.onSelect) == 'function'
        @ui.typeaheadElement.on 'typeahead:selected typeahead:autocompleted', @options.onSelect

