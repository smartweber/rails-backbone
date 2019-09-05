@Omega.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  class Entities.Company extends App.Entities.Model
    urlRoot: -> Routes.api_companies_path()
    paramRoot: 'company'
    specialMapping:
      QQQ:
        coefficient: 44.4
        simpleName: "Nasdaq"
        position: 3
      DIA:
        coefficient: 100.1
        simpleName: "Dow Jones"
        position: 1
      SPY:
        coefficient: 10.01
        simpleName: "S&P 500"
        position: 2

    to_param: ->
      @get('abbr')

    follow: (currentUser) ->
      relationship = @get('relationship')
      relationship.save null,
        success: =>
          @set followers_count: @get('followers_count') + 1
          currentUser.set following_companies_count: currentUser.get('following_companies_count') + 1

    unfollow: (currentUser) ->
      relationship = @get('relationship')
      relationship.destroy success: (model, response) =>
        relationship = App.request "new:relationship:entity", @
        @set
          relationship: relationship
          followers_count: @get('followers_count') - 1
        currentUser.set following_companies_count: currentUser.get('following_companies_count') - 1

    normalizedAbbr: ->
      s(@get('abbr')).underscored().value()

  class Entities.CompanyCollection extends App.Entities.Collection
    model: Entities.Company

  API =
    getCompanyCollectionFromUrl: (url) ->
      companiesCollection = new Entities.CompanyCollection
      companiesCollection.url = url
      companiesCollection.fetch()
      companiesCollection

    getCompany: (abbr) ->
      company = new Entities.Company
      company.url = Routes.api_company_path abbr
      company.fetch()
      company

  App.reqres.setHandler "get:company:entity", (abbr) ->
    API.getCompany abbr

  App.reqres.setHandler "get:trending_stocks:company:entities", ->
    API.getCompanyCollectionFromUrl Routes.trending_api_companies_path()

  App.reqres.setHandler "get:market_snapshot:company:entities", ->
    collection = API.getCompanyCollectionFromUrl Routes.market_snapshot_api_companies_path()
    collection.comparator = (model) ->
      model.specialMapping[model.get('abbr')].position
    collection.sort()
    collection

  App.reqres.setHandler "get:user:following:companies", (userId) ->
    API.getCompanyCollectionFromUrl Routes.api_user_following_companies_path(userId)

  App.reqres.setHandler "get:user:company:recommendations", (userId) ->
    # if userId
    #   API.getCompanyCollectionFromUrl Routes.companies_api_recommendations_path(userId)
    # else
    new Entities.CompanyCollection
