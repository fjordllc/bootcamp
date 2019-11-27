# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby RUBY_VERSION

gem "rails", "~> 6.0.1"
gem "puma", "~> 4.1"
gem "sass-rails", ">= 6"
gem "webpacker", "~> 4.0"
gem "jbuilder", "~> 2.7"
gem "bootsnap", ">= 1.4.2", require: false

# not default
gem "pg"
gem "coffee-rails", "~> 5.0.0"
gem "dynamic_form"
gem "slim-rails"
gem "jquery-rails"
gem "sorcery"
gem "oauth2"
gem "acts_as_list"
gem "diffy"
gem "slack-notifier"
gem "typhoeus"
gem "kaminari"
gem "font-awesome-sass", "~> 5.6.1"
gem "sassc-rails"
gem "autoprefixer-rails"
gem "ransack"
gem "rack-user_agent"
gem "meta-tags"
gem "rack-cors", require: "rack/cors"
gem "cocoon"
gem "active_decorator"
gem "rollbar"
gem "rails-i18n"
gem "google-cloud-storage", "~> 1.3", require: false
gem "mini_magick"
gem "commonmarker"
gem "stripe", "~> 4.5.0"
gem "acts-as-taggable-on", "~> 6.5"
gem "rqrcode"
gem "jp_prefecture"
gem "active_storage_validations"

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
  gem "rails-erd"
  gem "heavens_door"
  gem "rubocop", require: false
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "slim_lint"
  gem "bullet"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "webdrivers"

  # not default
  gem "webmock"
end
