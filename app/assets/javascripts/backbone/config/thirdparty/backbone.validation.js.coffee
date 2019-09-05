do (Omega, Backbone, $) ->

  _.extend Backbone.Validation.validators,
    equalToFormInput: (value, attr, equalTo, model, computed) ->
      formInput = $('[data-validation='+equalTo+']')
      if formInput.length > 1
        throw new Error "Can't figure out which form input to validate. Expected 1, found: #{formInput.length}."
      if (value != formInput.val())
        return @format(Backbone.Validation.messages.equalTo, @formatLabel(attr, model), @formatLabel(equalTo, model))

    maxCashtags: (value, attr, customValue, model) ->
      formInput = $('[data-validation='+attr+']')
      if formInput.length > 1
        throw new Error "Can't figure out which form input to validate. Expected 1, found: #{formInput.length}."
      if formInput.val() != "" and (formInput.val().match(/(^|\W)(\$[a-z\d][\w-]*)/ig) ||  []).length > customValue
        return "Can't contain more than 3 cashtags"

    pageSpecificCashtagRequired: (value, attr, customValue, model) ->
      currentPageCashtag = Omega.request "current:page:cashtag"
      # Company page - continue
      if currentPageCashtag
        regexp = new RegExp("(^|\\W)((\\$#{currentPageCashtag})(\\z|\\s)+)")
        # since backbone validates on set() and returned can contain html we need to clean the value
        strippedValue = s(value).stripTags().value()
        if strippedValue.match(regexp) == null
          return "$#{currentPageCashtag} should be mentioned in the post"

    checkboxSet: (value, attr, requiredValue, model) ->
      formInput = $('[data-validation='+attr+']:first')
      if formInput.length > 1
        throw new Error "Can't figure out which form input to validate. Expected 1, found: #{formInput.length}."
      unless formInput.is(':checked')
        return @format(Backbone.Validation.messages.acceptance, @formatLabel(attr, model))

  _.extend Backbone.Validation.patterns,
    name: /^(?!.*[\.\-]{2})(?!.*[\s]{2})[a-zA-Z]+[a-zA-Z\'\.\-\s]+$/
    username: /^(?!.*[-]{2})[a-zA-Z0-9][a-zA-Z0-9-]*$/

  _.extend Backbone.Validation.messages,
    name: 'Should consist of at least two words with second one having length of at least 2 symbols'
    username: 'Can only contain english symbols and numbers'
