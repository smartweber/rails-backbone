source 'https://rubygems.org'

# Fast webserver
gem 'thin', require: false
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
gem 'font-awesome-sass', '~> 4.3.0'
# Use mysql2 as the database for Active Record
gem 'mysql2', '~> 0.4.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.0.beta1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Easier form generation
gem 'simple_form'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '2.3.0'
# Build JSON APIs the same way you render templates
gem 'rabl', '~> 0.11.6'
# JSON parser for rabl
gem 'oj'
# Variables sharing between rails and javascript
gem 'gon'
# Shares rails-defined routes to javascript
gem 'js-routes'
# Haml template engine
gem 'haml-rails'
# Embedded COffeescript templating engine https://github.com/sstephenson/eco
gem 'eco'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Fixes https redirect problem for open uri
gem 'open_uri_redirections'
# Authentication
gem 'devise', '~> 3.5.1'
# Authorization
gem 'pundit', github: 'elabs/pundit', ref: '73ec66be'
# Scrapping
gem 'nokogiri'
# Url shortener
gem 'shortener'
# File attachments
gem 'carrierwave', '0.10.0'
# Imageworks
gem 'mini_magick', '3.8.0'
# File storage
gem 'fog', '~> 1.36.0'
# Pagination
gem 'kaminari'
# Elasticsearch wrapper
gem 'searchkick', '1.0.3'
# Parallel http requests/responses
gem "typhoeus"
# See typeahead.js - autocomplete by twitter
gem 'typeahead-rails'
# Ruby wrapper of bower(packages manager) https://github.com/rharriso/bower-rails
gem "bower-rails", "~> 0.10"
# Fast key-value storage
gem 'redis'
# Redis cache/sessions storage
gem 'redis-rails'
# Delayed jobs
gem 'sidekiq'
# DJ tracking
gem 'sidekiq-status'
# Requirement for sidekiq-webui
gem 'sinatra'
# Cron jobs
gem 'whenever', require: false
# Websockets/SSE
gem 'faye'
# Redis storage implementation for faye
gem 'faye-redis'
# Process-management
gem 'foreman', require: false
# RSS
gem 'feedjira'
# Pretty displaying of pre-generated API documentation
gem "apitome"
# Builds interfaces for data management
gem 'activeadmin', github: 'activeadmin'
# Error catcher
gem 'airbrake'
# Jaccard Index calculation
gem 'jaccard'
# Determining keywords in a text
gem 'highscore'
# Fast stemming for highscore
gem 'fast-stemmer'
# Assets in javascript
gem 'js_assets'
# All kind of twitter goodness but most of all - special words extractor
gem 'twitter-text'
# List functionality for models
gem 'acts_as_list', github: 'naive/acts_as_list', branch: :monkeypatch
# Drag-n-drop sorting for activeadmin index
gem 'activeadmin-sortable'
# Datetime fields nicely editing
gem 'active_admin_datetimepicker'
# Sanitizing of HTML input
gem 'sanitize'
# Google search API
gem 'google-api-client', '0.9.pre4'
# replacement for the URI implementation
gem 'addressable'
# A Redis client for EventMachine
gem 'em-hiredis'
# Webserver
gem 'puma'
# SDK for AWS
gem 'aws-sdk-rails'
# sendgrid integration
gem 'sendgrid', github: 'naive/sendgrid'
# prerendering pages for SEO purposes
gem 'prerender_rails'
# TinyMCE WYSIWYG editor
gem 'tinymce-rails'
# Image uploading for tinymce
gem 'tinymce-rails-imageupload', '~> 4.0.0.beta'
gem 'sitemap_generator'
# SEO Friendly IDs generator
gem 'friendly_id', '~> 5.1.0'


group :development, :test, :staging do
  # Fake random stuff generation for tests
  gem 'faker', '1.4.2'
  # Factories for tests
  gem 'factory_girl_rails'
end

group :development, :test do
  # Call 'binding.pry' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 1.3'
  # Mutes assets loading messages in webserver output
  gem 'quiet_assets'
  # API docs generation basing on acceptance tests https://github.com/zipmark/rspec_api_documentation
  gem 'rspec_api_documentation'
end

group :development do
  # Better error pages with console access
  gem "better_errors"
  # Extends fuctions of "better_errors" gem
  gem "binding_of_caller"
  # Database queries optimization
  gem "bullet"
  # Instant opening of sent emails with Launchy
  gem "letter_opener"

  # Multi-stage deployment
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.1.6'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'

end

group :test do
  gem 'rspec-rails', '3.3.2'
  # Tracking specs changes & running corresponding tests
  gem 'guard-rspec'
  # For old specs compatability since its were extracted to separate gem
  gem 'rspec-its'
  gem 'capybara', '~> 2.5'
  # Allows making screenshots in integration tests
  gem 'capybara-screenshot'
  # Headless integration testing
  gem 'capybara-webkit'
  # Integration testing with a browser instance
  gem 'selenium-webdriver', '2.46.2'
  # Cleaning database between passes ensuring database always stays clean
  gem 'database_cleaner', '1.5.1'
  # Request stubbing
  gem 'webmock', require: false
  # PhantomJS driver for Capybara
  gem 'poltergeist', github: 'teampoltergeist/poltergeist', branch: :master
  # One-line tets for Rails common functionality
  gem 'shoulda-matchers'
  # Records first and fakes future external requests
  gem 'vcr', '~> 3.0.1'
  # Proper progressing displaying
  gem 'fuubar'
  # Time traveling for tests
  gem 'timecop'
end
