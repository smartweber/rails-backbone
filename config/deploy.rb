# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'omega'
set :repo_url, 'git@bitbucket.org:stockharp/omega.git'

set :user, "deploy"
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

set :assets_roles, [:web]
set :whenever_roles, [:cron]

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :info

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/google_credentials.json')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/assets', 'public/system', 'public/uploads')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :rvm_type, :user
set :rvm_ruby_version, '2.2.3@stockharp'

set :nvm_type, :user
set :nvm_node, 'v0.12.4'
set :nvm_map_bins, %w{node npm}
set :nvm_roles, [:web]

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:schema:load'
        end
      end
    end
  end

end
