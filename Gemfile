# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rails", "~> 5.2.0"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails", "~> 4.2"
gem "bootsnap", ">= 1.1.0", require: false
gem "dynamic_form"
gem "gravatarify"
gem "slim-rails"
gem "jquery-rails"
gem "puma", "~> 3.11"
gem "simple_enum"
gem "sorcery"
gem "oauth2"
gem "acts_as_list"
gem "feedjira", "2.0.0"
gem "curb", "~> 0.8.8"
gem "jbuilder", "~> 2.5"
gem "diffy"
gem "slack-notifier"
gem "typhoeus"
gem "kaminari"
gem "record_tag_helper", "~> 1.0"
gem "sprockets", ">= 3.0.0"
gem "sprockets-es6"
gem "pg"
gem "bootstrap", "= 4.0.0.alpha6"
gem "oulu"
gem "font-awesome-sass", "~> 5.3.1"
gem "sassc-rails"
gem "ransack"
gem "rack-user_agent"
gem "meta-tags"
gem "webpacker"
gem "paperclip"
gem "paperclip-meta"
gem "fog", "1.40.0"
gem "rack-cors", require: "rack/cors"
gem "cocoon"
gem "active_decorator"
gem "rollbar"

group :production, :staging do
  gem "newrelic_rpm"
end

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]

  # not default
  gem "pry-byebug"
  gem "simple_seed"
end

group :development do
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"

  # not default
  gem "letter_opener"
  gem "xray-rails"
  gem "rails-erd"
end

group :test do
  gem "capybara", ">= 2.15", "< 4.0"
  gem "selenium-webdriver"
  gem "chromedriver-helper"

  # not default
  gem "minitest", "~> 5.10", "!= 5.10.2"
end
