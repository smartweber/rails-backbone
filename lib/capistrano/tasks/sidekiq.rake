namespace :god do
  namespace :sidekiq do
    desc "Restart Sidekiq  workers"
    task :restart do
      on roles(:worker) do
        within release_path do
          with RAILS_ENV: fetch(:rails_env) do
            execute :god, "restart sidekiq"
          end
        end
      end
    end

    desc "Stop Sidekiq workers"
    task :stop do
      on roles(:worker) do
        within release_path do
          with RAILS_ENV: fetch(:rails_env) do
            execute :god, "stop sidekiq; true"
          end
        end
      end
    end

    desc "Start Sidekiq workers"
    task :start do
      on roles(:worker) do
        within release_path do
          with RAILS_ENV: fetch(:rails_env) do
            execute :god, "start sidekiq"
          end
        end
      end
    end

    desc "Show status of Sesque workers"
    task :status do
      on roles(:worker) do
        within release_path do
          with RAILS_ENV: fetch(:rails_env) do
            execute :god, "status sidekiq || true"
          end
        end
      end
    end

    desc "Unmonitor Sidekiq workers"
    task :unmonitor do
      on roles(:worker) do
        within release_path do
          with RAILS_ENV: fetch(:rails_env) do
            execute :god, "unmonitor sidekiq"
          end
        end
      end
    end

    desc "Monitor Sidekiq workers"
    task :monitor do
      on roles(:worker) do
        within release_path do
          with RAILS_ENV: fetch(:rails_env) do
            execute :god, "sidekiq"
          end
        end
      end
    end

    desc "Unmonitor Sidekiq, then send QUIT signal to exit after current job is processed"
    task :quit do
      on roles(:worker) do
        within release_path do
          with RAILS_ENV: fetch(:rails_env) do
            execute :god, "unmonitor sidekiq"
            execute :god, "signal sidekiq USR1"
          end
        end
      end
    end
  end
end
