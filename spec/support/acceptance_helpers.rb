module Acceptance
  module JsonHelpers
    def json
      @json ||= JSON.parse(response_body)
    end
  end
end
