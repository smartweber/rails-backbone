JsRoutes.setup do |config|
  config.default_url_options = { trailing_slash: false, protocol: 'http', host: 'localhost', port: 3000 }
  config.url_links = true
end