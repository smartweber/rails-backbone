namespace :assets do
  desc 'Sync assets across all app servers'
  task :sync do
    on roles (:web) do
      within current_path do
        roles(:app).each do  |server|
          execute :scp, "-pC #{manifest_file} #{server.user}@#{server.hostname}:#{shared_path}/#{manifest_file}"
        end
      end
    end
  end

  def manifest_file
    file = nil
    on roles(:web) do |server|
      within shared_path do
        file = capture :ls, "-a public/assets/.sprockets-manifest*.json"
      end
    end
    file
  end
end

after 'deploy:symlink:release', 'assets:sync'
