# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'image_processing', '~> 1.12'
gem 'jbuilder', '~> 2.7'
gem 'puma', '~> 6.3'
gem 'rails', '~> 6.1.4.4'
gem 'webpacker', '~> 5.0'

# not default
gem 'abstract_notifier', '~> 0.3.2'
gem 'active_decorator'
gem 'active_delivery'
gem 'active_flag'
gem 'active_storage_validations'
gem 'acts_as_list'
gem 'acts-as-taggable-on'
gem 'addressable'
gem 'any_login'
gem 'cocoon'
gem 'commonmarker'
gem 'countries', '>= 5.5.0'
gem 'country_select'
gem 'data_migrate'
gem 'diffy'
gem 'discord-notifier'
gem 'discordrb', github: 'shardlab/discordrb', require: false
gem 'good_job', '~> 3.14', github: 'komagata/good_job'
gem 'google-cloud-storage', '~> 1.25', require: false
gem 'holiday_jp'
gem 'icalendar', '~> 2.8'
gem 'jquery-rails'
gem 'kaminari'
gem 'mentionable', '~> 0.3.0'
gem 'meta-tags'
gem 'mini_magick'
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false # TODO: Remove it if you use rails 7.0.1
gem 'newspaper'
gem 'oauth2'
gem 'omniauth', '~> 2.1.1'
gem 'omniauth-github', '~> 2.0.1'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'postmark-rails'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-user_agent'
gem 'rails_autolink'
gem 'rails-i18n', '~> 6.0.0'
gem 'ransack'
gem 'react-rails'
gem 'recaptcha', '~> 5.12'
gem 'rollbar'
gem 'rss'
gem 'ruby-openai'
gem 'rubyzip'
gem 'slim-rails'
gem 'sorcery', '~> 0.16.2'
gem 'sorcery-jwt'
gem 'stripe'
gem 'stripe-i18n', git: 'https://github.com/komagata/stripe-i18n', branch: 'update-depencency'
gem 'tzinfo', '~> 2.0', '>= 2.0.6'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # not default
  gem 'pry-byebug'
  gem 'syntax_suggest'
  gem 'traceroute'
end

group :development do
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 4.1.0'

  # not default
  gem 'bullet'
  gem 'bundle_outdated_formatter'
  gem 'foreman'
  gem 'letter_opener_web', '~> 2.0'
  gem 'rack-dev-mark'
  gem 'rack-mini-profiler', '~> 2.0', require: false
  gem 'rubocop', require: false
  gem 'rubocop-fjord', '~> 0.3.0', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'slim_lint'
  gem 'view_source_map'
end

group :test do
  gem 'capybara'
  gem 'minitest-ci'
  gem 'minitest-retry'
  gem 'selenium-webdriver'
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock'
end
