God.log_file = '/home/deploy/apps/omega/shared/log/god.log'
God.log_level = :warn
RAILS_ROOT = ENV['RAILS_ROOT'] = '/home/deploy/apps/omega/current'
God.pid_file_directory = File.join(RAILS_ROOT, %w(tmp pids))
God.load RAILS_ROOT+'/config/god/*.god'
