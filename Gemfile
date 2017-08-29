source "https://rubygems.org"

ruby "2.4.1"

gem "rails", "~> 5.1.3"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails", "~> 4.2"
gem "dynamic_form"
gem "gravatarify"
gem "slim-rails"
gem "jquery-rails"
gem "puma", "~> 3.0"
gem "simple_enum"
gem "sorcery"
gem "acts_as_list"
gem "feedjira", "2.0.0"
gem "curb", "~> 0.8.8"
gem "turbolinks", "~> 5"
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
gem "sassc-rails"
gem "ransack"
gem "rack-user_agent"

group :production, :staging do
  gem "newrelic_rpm"
  gem "rails_12factor"
end

group :development do
  gem "pry-remote"
  gem "xray-rails"
  gem "web-console"
  gem "listen", "~> 3.0.5"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "letter_opener"
  gem "letter_opener_web"
end

group :development, :test do
  gem "capybara", "~> 2.8"
  gem "pry-byebug"
  gem "simple_seed"
  gem "byebug", platform: :mri
  gem "minitest", "~> 5.10", "!= 5.10.2"
  gem 'selenium-webdriver'
end
