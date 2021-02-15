# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby RUBY_VERSION

gem 'bootsnap', '>= 1.4.2', require: false
gem 'image_processing', '~> 1.2'
gem 'jbuilder', '~> 2.7'
gem 'puma', '~> 4.3'
gem 'rails', '~> 6.0.3.2'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 4.0'

# not default
gem 'active_decorator'
gem 'active_flag'
gem 'active_storage_validations'
gem 'acts_as_list'
gem 'acts-as-taggable-on', '~> 6.5'
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
gem 'mentionable', '~> 0.2'
gem 'meta-tags'
gem 'oauth2'
gem 'omniauth'
gem 'omniauth-github'
gem 'pg'
gem 'postmark-rails'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-user_agent'
gem 'rails_autolink'
gem 'rails-i18n'
gem 'ransack'
gem 'rollbar'
gem 'rqrcode'
gem 'slack-notifier'
gem 'slim-rails'
gem 'sorcery'
gem 'sorcery-jwt'
gem 'stripe', '~> 4.5.0'
gem 'stripe-i18n'
gem 'sucker_punch', '~> 2.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # not default
  gem 'pry-byebug'
  gem 'traceroute'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  # not default
  gem 'bullet'
  gem 'bundle_outdated_formatter'
  gem 'letter_opener_web', '~> 1.0'
  gem 'rack-mini-profiler', require: false
  gem 'rubocop-fjord', require: false
  gem 'rubocop-minitest'
  gem 'rubocop-rails', require: false
  gem 'slim_lint'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
