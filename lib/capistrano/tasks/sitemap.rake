namespace :sitemaps do

  desc "Refreshes sitemaps"
  task :refresh do
    on roles(:web) do
      within release_path do
        with RAILS_ENV: fetch(:rails_env) do
          invoke 'deploy:sitemap:refresh'
        end
      end
    end
  end
end

after 'deploy:published', 'sitemaps:refresh'
