if !ENV['DISABLE_ASSET_FILTERING'] && (Rails.env.development? || Rails.env.test?)
  module Rack
    class CommonLogger

      FILTER_REGEXPS = [/\.css/, /\.js/, /\.png/, /\.jpg/, /\.gif/, /.ico/]

      def call_with_silencer(env)
        if FILTER_REGEXPS.any? { |re| re.match env['PATH_INFO'] }
          @app.call env
        else
          call_without_silencer(env)
        end
      end

      alias_method_chain :call, :silencer
    end
  end
end