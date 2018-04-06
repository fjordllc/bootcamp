source "https://rubygems.org"

ruby "2.4.2"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rails", "~> 5.1.3"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails", "~> 4.2"
gem "dynamic_form"
gem "gravatarify"
gem "slim-rails"
gem "jquery-rails"
gem "puma", "~> 3.7"
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
gem "sassc-rails"
gem "ransack"
gem "rack-user_agent"
gem "meta-tags"
gem "webpacker"
gem "paperclip"
gem "paperclip-meta"
gem "fog"
gem "rack-cors", require: "rack/cors"
gem "cocoon"
gem "active_decorator"

group :production, :staging do
  gem "newrelic_rpm"
end

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "capybara", "~> 2.13"
  gem "selenium-webdriver"

  # not default
  gem "minitest", "~> 5.10", "!= 5.10.2"
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
end
