== DEPLOYMENT


# Staging #

Run the following command to deploy the latest code on the staging environment.

```
bundle exec cap staging deploy
```

The above command will trigger all necessary actions on each servers
of the staging cloud.

# Roles #

There are separate servers for each roles (eg. web, app, worker).

## Web ##

The Web server has Nginx installed on it and which is responsible for handling incoming traffic to the application. It also act as a load balancer so it distributes traffic across multiple App servers.

## App ##

There might be more one one App servers. We use [Puma](http://puma.io/) as Rails application server. The following Capistrano tasks are available against App servers.

```
bundle exec cap staging puma:halt                      # Halt puma
bundle exec cap staging puma:phased-restart            # Phased-restart puma
bundle exec cap staging puma:restart                   # Restart puma
bundle exec cap staging puma:start                     # Start puma
buncle exec cap staging puma:status                    # Get status of puma
bundle exec cap staging puma:stop                      # Stop puma

```

## Worker ##

We are using [Sidekiq](http://sidekiq.org/) to process background jobs. Like App servers, there might be more than one *Worker* servers. Redis is installed on Worker1.

```
bundle exec cap staging god:sidekiq:quiet                  # Quiet sidekiq (stop processing new tasks)
bundle exec cap staging god:sidekiq:respawn                # Respawn missing sidekiq processes
bundle exec cap staging god:sidekiq:restart                # Restart sidekiq
bundle exec cap staging god:sidekiq:rolling_restart        # Rolling-restart sidekiq
bundle exec cap staging god:sidekiq:start                  # Start sidekiq
bundle exec cap staging god:sidekiq:stop                   # Stop sidekiq

```

## Faye ##

[Faye](http://faye.jcoglan.com/) is a publish-subscribe messaging system. Staging Faye server can be accessed at 52.25.31.51 and port 9293.

The following Capistrano tasks are available to manage Faye server.

```
bundle exec cap staging faye:restart                   # Restart Faye server
bundle exec cap staging faye:start                     # Start Faye server
bundle exec cap staging faye:stop                      # Stop faye server
```

## Database ##

Currently, we are using MySQL database. It resides on same instance as app server.

## ElasticSearch ##
Staging ElasticSearch is installed on 52.25.68.189. We don't need to do anything from Capistrano.

For all Capistrano tasks, run the following command.

```
bundle exec cap -T
```

# Assets Compilation #

We compile assets locally and then we upload them to remote servers. Otherwise, we need to install NodeJS and Bower on each Web and App servers.

```
cap assets:precompile              # Run the precompile task locally and sync with rsync
cap assets:upload                  # Upload compiled assets to Web and App servers

```

Note: These tasks will get automatically invoked after `bundle exec cap staging deploy`. So, we don't need to do this ourselves.




