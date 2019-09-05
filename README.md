== README

# Ruby version #
We're using ruby 2.2.3 currently.

# Ruby installation using RVM #

It's recommended to use ruby version management software like RVM. [Install it](https://rvm.io/rvm/install) following single-user stable version installation route. After RVM installed run in a new terminal:
```
#!shell


rvm install 2.2.3
```

# Dependencies description #

  We're using **Redis** for our delayed jobs/fast storage/session storage.

  **Mysql 5.6.24** is currently used as a database.

  **Elasticsearch** is used for our fast-search tasks.

  **Imagemagick** is being used for image processing.

# Windows dependencies installation route #

  There's none. Windows is not supported. Please use Ubuntu instead.

# OS X  dependencies installation route #
  You can easily satisfy all the dependencies using [homebrew](http://brew.sh/):

```
#!shell


brew install redis
brew install mysql
brew install elasticsearch
brew install imagemagick
```

  To start now and start the installed daemons automatically on startup run following commands:

```
#!shell

ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
ln -sfv /usr/local/opt/elasticsearch/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist
```
  You may need to install **Qt** if you don't have it. [Qt installation instructions](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit).
  There's a possibility that you'll have to install Java/OpenJDK in the process.

# Linux-based dependencies installation route #
  Note: This instructions are for Linux-based machines.

 [Install Redis](http://redis.io/topics/quickstart).

 [Install Mysql](https://dev.mysql.com/doc/refman/5.6/en/linux-installation-native.html)

 [Install Elasticsearch](http://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html). There's a possibility that you'll have to install Java/OpenJDK in the process.

 Install ImageMagick with:


```
#!shell

sudo apt-get install imagemagick --fix-missing
```
  You may need to install **Qt** if you don't have it. [Qt installation instructions](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit).
# Ruby on Rails dependencies #

To satisfy all other project dependencies run:

```
#!shell

bundle install
```
This would install all the gems(extensions) that project uses.

# Database creation #
Run:
```
#!shell

bundle exec rake db:setup
```
# Database population with data #
Run to populate Companies table from CSV files:
```
#!shell

bundle exec rake companies:import
```
Run to fetch latest News from 3rd party:
```
#!shell

bundle exec rake feeds:fetch
```
# Running a rails server #
### Services (job queues, cache servers, search engines, etc.) ###


Run elasticsearch with(assuming you're in the elasticsearch folder):
```
#!shell

bin/elasticsearch
```
**If that's your first time starting this application you'll need to create search indexes.** Execute this:
```
#!shell


bundle exec rake searchkick:reindex:all
```

Start redis with:

```
#!shell

redis-server
```
Run delayed job queues/faye/rails with:

```
#!shell

foreman start
```

# Additional info #

### Documentation ###


API documentation are available at [http://localhost:3000/api/docs](http://localhost:3000/api/docs) once you run a rails webserver.
This documentation are generated using [rspec_api_documentation](https://github.com/zipmark/rspec_api_documentation) basing on acceptance tests at *spec/acceptance*. Documentation stored in project repo and you can re-generate it by following command:

```
#!shell


bundle exec rake docs:generate
```
### Javascript libraries ###


Project uses [bower-rails](https://github.com/rharriso/bower-rails) for managing external javascript dependencies.
You can install all declared(in Bowerfile) dependencies with:

```
#!shell


bundle exec rake bower:install && bundle exec rake bower:clean
```
Be sure to pinpoint new dependencies in *vendor/assets/javascripts/vendor.js*

### Git branching model ###


We have two main branches now: master and staging. Developer should create his initial branches from staging and merge them back into staging by pull requests.
From there one of the persons responsible for bringing changes into [staging server](http://staging.stockharp.com/) would merge them into staging branch(and later master) and deploy once needed.

### How to run the test suite ###

```
#!shell
rspec spec/

```

### Regarding Quotemedia (QM) data ###

If you see an issue regarding no data with 'market_snapshot' or 'trending', it is because there is a restriction on this 3rd party application. The staging branch is developed for the staging server at (staging.stockharp.com), therefore you must go to the fake_data branch in order to see the home page show up with data. 