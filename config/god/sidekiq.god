rails_root ||= ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env ||= ENV['RAILS_ENV'] || 'staging'

God.watch do |w|
  w.name = "sidekiq-worker"
  w.group = 'sidekiq'
  w.interval = 30.seconds
  w.env = {"RAILS_ENV" => rails_env}
  w.start = "bundle exec sidekiq --index 0 --pidfile /home/deploy/apps/omega/shared/tmp/pids/sidekiq.pid --environment #{rails_env} --logfile /home/deploy/apps/omega/shared/log/sidekiq.log -v --daemon
"
  w.log   = "#{rails_root}/log/sidekiq_god.log"
  w.dir   = rails_root

  w.pid_file = "/home/deploy/apps/omega/shared/tmp/pids/sidekiq.pid"

  # retart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 350.megabytes
      c.times = 2
    end

    #on.condition(:restart_file_touched) do |c|
    #  c.interval = 5.seconds
    #  c.restart_file = File.join(rails_root, 'tmp', 'restart.txt')
    #end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end
