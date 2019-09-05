# If it's Faye instance runned by Thin - skip running service
# TODO: move that to separately running script?
LiveRefresh.start if defined?(::Puma) && (File.basename($0) == 'puma' or ENV['detected_server_name'] == "Rack::Handler::Puma")
