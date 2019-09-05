require 'rails_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'

RspecApiDocumentation.configure do |config|
  config.format = :json
  config.curl_host = 'http://localhost:3000'
  config.api_name = "Omega"
  config.curl_headers_to_filter = %w(Host Cookie)
  config.post_body_formatter = Proc.new { |params| params.to_json }
  config.request_headers_to_include = %w(Accept Content-Type)
  config.response_headers_to_include = %w(Cache-Control Content-Type)
end
