# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.6'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'ffi', '1.17.1'
gem 'image_processing', '~> 1.12'
gem 'jbuilder', '~> 2.7'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.7.10'
gem 'webpacker', '~> 5.0'

# not default
gem 'abstract_notifier', '~> 0.3.2'
gem 'active_decorator'
gem 'active_delivery', '0.4.4'
gem 'active_flag'
gem 'active_storage_validations'
gem 'acts_as_list'
gem 'acts-as-taggable-on'
gem 'addressable'
gem 'any_login'
gem 'cocooned'
gem 'concurrent-ruby', '1.3.4'
gem 'countries', '>= 5.5.0'
gem 'country_select'
gem 'data_migrate', '9.2.0'
gem 'diffy'
gem 'discord-notifier'
gem 'discordrb', '~> 3.5', require: false
gem 'doorkeeper'
gem 'flipper-active_record', '~> 1.3'
gem 'good_job', '~> 3.14', github: 'komagata/good_job'
gem 'google-cloud-storage', '~> 1.25', require: false
gem 'holiday_jp'
gem 'icalendar', '~> 2.8'
gem 'interactor', '~> 3.0'
gem 'jp_prefecture', '~> 1.1'
gem 'jquery-rails'
gem 'kaminari'
gem 'kramdown'
gem 'kramdown-parser-gfm'
gem 'mentionable', '~> 0.3.0'
gem 'meta-tags'
gem 'mini_magick'
gem 'mutex_m', '0.1.1'
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false # TODO: Remove it if you use rails 7.0.1
gem 'newspaper'
gem 'oauth2'
gem 'omniauth', '~> 2.1.1'
gem 'omniauth-discord'
gem 'omniauth-github', '~> 2.0.1'
gem 'omniauth-rails_csrf_protection'
gem 'opengraph_parser'
gem 'parser', '3.2.2.4'
gem 'pg', '~> 1.4.6'
gem 'postmark-rails'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-user_agent'
gem 'rails_autolink'
gem 'rails-i18n', '~> 6.0.0'
gem 'rails-patterns', '~> 0.2'
gem 'ransack', '3.1.0'
gem 'react-rails'
gem 'recaptcha', '~> 5.12'
gem 'rollbar'
gem 'rss'
gem 'ruby-openai'
gem 'rubyzip'
gem 'slim-rails'
gem 'sorcery', '~> 0.16.2'
gem 'sorcery-jwt'
gem 'stringio', '3.0.1.2'
gem 'stripe'
gem 'stripe-i18n', git: 'https://github.com/komagata/stripe-i18n', branch: 'update-depencency'
gem 'tzinfo', '~> 2.0', '>= 2.0.6'
gem 'view_component'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # not default
  gem 'dotenv-rails'
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
  gem 'foreman'
  gem 'letter_opener_web', '~> 2.0'
  gem 'rack-dev-mark'
  gem 'rack-mini-profiler', '~> 2.0', require: false
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-fjord', '~> 0.3.0', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'slim_lint'
  gem 'view_source_map'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'minitest-ci'
  gem 'minitest-retry'
  gem 'minitest-stub_any_instance'
  gem 'selenium-webdriver', '~> 4.17.0'
  gem 'vcr'
  gem 'webmock'
end
