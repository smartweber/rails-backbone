require 'google/apis/customsearch_v1'

# TODO: replace plain string credentials with one that read from google_credentials.json
module GoogleApi
  def self.client
    @client ||= GoogleApi::CustomsearchService.new
  end

  class CustomsearchService
    def initialize
      @service = Google::Apis::CustomsearchV1::CustomsearchService.new
      set_key
    end

    def find_first_by(query)
      result = @service.list_cses(query,
                                   img_size: [:large, :xlarge, :xxlarge],
                                   safe: :high,
                                   search_type: :image,
                                   cx: APP_CONFIG[:google_api][:search_engine_id])
      result.items.first
    end

    def set_key
      @service.key = APP_CONFIG[:google_api][:server_key]
    end
  end
end
