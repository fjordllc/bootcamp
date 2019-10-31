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
gem "slim-rails"
gem "jquery-rails"
gem "puma", "~> 3.11"
gem "sorcery"
gem "oauth2"
gem "acts_as_list"
gem "jbuilder", "~> 2.5"
gem "diffy"
gem "slack-notifier"
gem "typhoeus"
gem "kaminari"
gem "record_tag_helper", "~> 1.0"
gem "sprockets", ">= 3.0.0"
gem "sprockets-es6"
gem "pg"
gem "font-awesome-sass", "~> 5.6.1"
gem "sassc-rails"
gem "autoprefixer-rails"
gem "ransack"
gem "rack-user_agent"
gem "meta-tags"
gem "webpacker"
gem "rack-cors", require: "rack/cors"
gem "cocoon"
gem "active_decorator"
gem "rollbar"
gem "rails-i18n"
gem "google-cloud-storage", "~> 1.3", require: false
gem "mini_magick"
gem "activestorage-validator"
gem "commonmarker"
gem "stripe", "~> 4.5.0"
gem "acts-as-taggable-on"
gem "rqrcode"
gem "jp_prefecture"
gem "holiday_jp"

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
  gem "heavens_door"
  gem "rubocop", require: false
  gem "rubocop-performance"
  gem "slim_lint"
  gem "bullet"
end

group :test do
  gem "capybara", ">= 2.15", "< 4.0"
  gem "selenium-webdriver"

  # not default
  gem "minitest", "~> 5.10", "!= 5.10.2"
  gem "webdrivers", "~> 3.0"
  gem "webmock"
end
