# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby RUBY_VERSION

gem "rails", "~> 6.0.3.2"
gem "puma", "~> 4.3"
gem "sass-rails", ">= 6"
gem "webpacker", "~> 4.0"
gem "jbuilder", "~> 2.7"
gem "bootsnap", ">= 1.4.2", require: false
gem "image_processing", "~> 1.2"

# not default
gem "pg"
gem "coffee-rails", "~> 5.0.0"
gem "slim-rails"
gem "jquery-rails"
gem "sorcery"
gem "oauth2"
gem "acts_as_list"
gem "diffy"
gem "slack-notifier"
gem "kaminari"
gem "ransack"
gem "rack-user_agent"
gem "meta-tags"
gem "rack-cors", require: "rack/cors"
gem "cocoon"
gem "active_decorator"
gem "rollbar"
gem "rails-i18n"
gem "google-cloud-storage", "~> 1.25", require: false
gem "commonmarker"
gem "stripe", "~> 4.5.0"
gem "acts-as-taggable-on", "~> 6.5"
gem "rqrcode"
gem "jp_prefecture"
gem "active_storage_validations"
gem "any_login"
gem "sucker_punch", "~> 2.0"
gem "stripe-i18n"
gem "holiday_jp"
gem "mentionable", "~> 0.2"
gem "omniauth"
gem "omniauth-github"
gem "postmark-rails"
gem "rails_autolink"
gem "active_flag"
gem "sorcery-jwt"
gem "data_migrate"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]

  # not default
  gem "pry-byebug"
  gem "webmock"
  gem "traceroute"
end

group :development do
  gem "web-console", ">= 3.3.0"
  gem "listen", "~> 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"

  # not default
  gem "letter_opener"
  gem "rubocop", require: false
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-minitest"
  gem "slim_lint"
  gem "bullet"
  gem "bundle_outdated_formatter"
  gem "rack-mini-profiler", require: false
end

group :test do
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "webdrivers"
end
