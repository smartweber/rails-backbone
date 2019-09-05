require 'pry'
namespace :load do
  task :defaults do
    set :faye_default_hooks, -> { true }
    set :faye_role, :faye
    set :faye_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
    set :faye_conf, -> { File.join(current_path, 'lib', 'faye_server', 'faye_server.yml') }
    set :faye_pid, -> { File.join(shared_path, 'tmp', 'pids', 'faye.pid') }
    set :faye_rackup, -> { File.join(current_path, 'lib', 'faye_server', 'config.ru') }
    set :ssl_cert_path, -> { '/etc/nginx/ssl/cert/stockharp-bundle.crt' }
    set :ssl_key_path, -> { '/etc/nginx/ssl/key/stockharp.key' }

    # Rbenv and RVM integration
    set :rvm_map_bins, fetch(:rvm_map_bins).to_a.concat(%w{ thin })

  end
end

namespace :deploy do
  before :starting, :check_faye_hooks do
    invoke 'faye:add_default_hooks' if fetch(:faye_default_hooks)
  end
end

namespace :faye do
  desc "Start faye server"
  task :start do
    on roles (fetch(:faye_role)) do
      within current_path do
        with rack_env: fetch(:faye_env) do
          faye = YAML.load(File.read('config/app_config.yml'))[fetch(:faye_env).to_s]['faye']
          nossl_start_command = "start -R #{fetch(:faye_rackup)} -p #{faye['port']} -C #{fetch(:faye_conf)}"
          ssl_options = " --ssl --ssl-disable-verify --ssl-cert-file #{fetch(:ssl_cert_path)} --ssl-key-file #{fetch(:ssl_key_path)}"
          start_command = (fetch(:faye_env) == :production) ? nossl_start_command.concat(ssl_options) : nossl_start_command
          execute :bundle, 'exec', :thin, start_command
        end
      end
    end
  end

  %w[stop].map do |command|
    desc "#{command} faye"
    task command do
      on roles (fetch(:faye_role)) do
        within current_path do
          with rack_env: fetch(:faye_env) do
            if test "[ -f #{fetch(:faye_pid)} ]"
              if test "kill -0 $( cat #{fetch(:faye_pid)} )"
                execute :bundle, 'exec', :thin, "#{command} -R #{fetch(:faye_rackup)} -C #{fetch(:faye_conf)}"
              else
                # delete stale pid, process is not running
                execute :rm, fetch(:faye_pid)
              end
            else
              # pid not found, so faye is not running
              warn "Faye is not running"
            end
          end
        end
      end
    end
  end

  desc "Restart faye"
  task :restart do
    on roles (fetch(:faye_role)) do
      within current_path do
        with rack_env: fetch(:faye_env) do
          if test "[ -f #{fetch(:faye_pid)} ]" and test "kill -0 $( cat #{fetch(:faye_pid)} )"
            execute :bundle, 'exec', :thin, "restart -R #{fetch(:faye_rackup)} -C #{fetch(:faye_conf)}"
          else
            # Faye server is not running, run it
            invoke 'faye:start'
          end
        end
      end
    end
  end

  task :add_default_hooks do
    after 'deploy:finished', 'faye:restart'
  end
end


