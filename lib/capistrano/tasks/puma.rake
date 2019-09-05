namespace :load do
  task :defaults do
    set :puma_default_hooks, -> { true }
    set :puma_role, :app
    set :puma_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
    # Configure "min" to be the minimum number of threads to use to answer
    # requests and "max" the maximum.
    set :puma_state, -> { File.join(shared_path, 'tmp', 'pids', 'puma.state') }
    set :puma_pid, -> { File.join(shared_path, 'tmp', 'pids', 'puma.pid') }
    set :puma_conf, -> { File.join(current_path, 'config', 'puma.rb') }

    # Rbenv and RVM integration
    set :rvm_map_bins, fetch(:rvm_map_bins).to_a.concat(%w{ puma pumactl })

  end
end

namespace :deploy do
  before :starting, :check_puma_hooks do
    invoke 'puma:add_default_hooks' if fetch(:puma_default_hooks)
  end
end

namespace :puma do

  desc 'Start puma'
  task :start do
    on roles (fetch(:puma_role)) do
      within current_path do
        with rack_env: fetch(:puma_env) do
          execute :bundle, 'exec', :puma, "-C #{fetch(:puma_conf)} --daemon"
        end
      end
    end
  end

  %w[halt stop status].map do |command|
    desc "#{command} puma"
    task command do
      on roles (fetch(:puma_role)) do
        within current_path do
          with rack_env: fetch(:puma_env) do
            if test "[ -f #{fetch(:puma_pid)} ]"
              if test "kill -0 $( cat #{fetch(:puma_pid)} )"
                execute :bundle, 'exec', :pumactl, "-S #{fetch(:puma_state)} #{command}"
              else
                # delete invalid pid file , process is not running.
                execute :rm, fetch(:puma_pid)
              end
            else
              #pid file not found, so puma is probably not running or it using another pidfile
              warn 'Puma not running'
            end
          end
        end
      end
    end
  end

  %w[phased-restart restart].map do |command|
    desc "#{command} puma"
    task command do
      on roles (fetch(:puma_role)) do
        within current_path do
          with rack_env: fetch(:puma_env) do
            if test "[ -f #{fetch(:puma_pid)} ]" and test "kill -0 $( cat #{fetch(:puma_pid)} )"
              # NOTE pid exist but state file is nonsense, so ignore that case
              execute :bundle, 'exec', :pumactl, "-S #{fetch(:puma_state)} #{command}"
            else
              # Puma is not running or state file is not present : Run it
              invoke 'puma:start'
            end
          end
        end
      end
    end
  end

  task :add_default_hooks do
    after 'deploy:finished', 'puma:restart'
  end

end
