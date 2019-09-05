namespace :load do
  task :defaults do
    set :rvm_map_bins, fetch(:rvm_map_bins).to_a.concat(%w(god))
  end
end

namespace :god do
  def god_is_running
    capture(:god, "status > /dev/null 2>&1 || echo 'god not running'") != 'god not running'
  end

  # Must be executed within SSHKit context
  def config_file
    "#{release_path}/config/god.god"
  end

  # Must be executed within SSHKit context
  def start_god
    execute :god, "-c #{config_file}"
  end

  desc "Start god and his processes"
  task :start do
    on roles(:worker) do
      within release_path do
        with RAILS_ENV: fetch(:rails_env) do
          start_god
        end
      end
    end
  end

  desc "Terminate god and his processes"
  task :stop do
    on roles(:worker) do
      within release_path do
        if god_is_running
          execute :god, "terminate"
        end
      end
    end
  end

  desc "Restart god's child processes"
  task :restart do
    on roles(:worker) do
      within release_path do
        with RAILS_ENV: fetch(:rails_env) do
          if god_is_running
            execute :god, "load #{config_file}"
            execute :god, "restart"
          else
            start_god
          end
        end
      end
    end
  end
end

after "deploy:publishing", "god:restart"
