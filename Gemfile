# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.4'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'image_processing', '~> 1.2'
gem 'jbuilder', '~> 2.7'
gem 'puma', '~> 5.5'
gem 'rails', '~> 6.1.3', '>= 6.1.3.1'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'

# not default
gem 'active_decorator'
gem 'active_flag'
gem 'active_storage_validations'
gem 'acts_as_list'
gem 'acts-as-taggable-on', '~> 7.0'
gem 'any_login'
gem 'cocoon'
gem 'coffee-rails', '~> 5.0.0'
gem 'commonmarker'
gem 'data_migrate'
gem 'diffy'
gem 'discord-notifier'
gem 'google-cloud-storage', '~> 1.25', require: false
gem 'holiday_jp'
gem 'jp_prefecture'
gem 'jquery-rails'
gem 'kaminari'
gem 'mentionable', '~> 0.2.1'
gem 'meta-tags'
gem 'oauth2'
gem 'omniauth', '~> 1.9.1'
gem 'omniauth-github', '~> 1.4.0'
gem 'pg'
gem 'postmark-rails'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-user_agent'
gem 'rails_autolink'
gem 'rails-i18n'
gem 'ransack'
gem 'rollbar'
gem 'slim-rails'
gem 'sorcery'
gem 'sorcery-jwt'
gem 'stripe'
gem 'stripe-i18n', git: 'https://github.com/komagata/stripe-i18n', branch: 'update-depencency'
gem 'sucker_punch', '~> 2.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # not default
  gem 'dead_end'
  gem 'pry-byebug'
  gem 'traceroute'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 4.1.0'

  # not default
  gem 'bullet'
  gem 'bundle_outdated_formatter'
  gem 'letter_opener_web', '~> 1.0'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'rubocop', require: false
  gem 'rubocop-fjord', '~> 0.2.0', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'slim_lint'
  gem 'view_source_map'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'minitest-retry'
  gem 'selenium-webdriver'
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock'
end
