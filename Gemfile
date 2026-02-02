# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.3'

gem 'bootsnap', require: false
gem 'ffi', '1.17.1'
gem 'image_processing', '>= 1.12.2', '< 2.0'
gem 'jbuilder'
gem 'puma', '>= 5.0'
gem 'rails', '8.1.1'
gem 'shakapacker', '~> 9.0'
gem 'sprockets-rails', '>= 2.0.0'
gem 'tailwindcss-rails', '~> 4.0'

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
gem 'csv'
gem 'data_migrate'
gem 'diffy'
gem 'discord-notifier'
gem 'discordrb', '~> 3.5', require: false
gem 'doorkeeper'
gem 'google-cloud-storage', '~> 1.25', require: false
gem 'google-cloud-video-transcoder'
gem 'google-id-token'
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
gem 'mission_control-jobs'
gem 'mutex_m', '0.1.1'
gem 'neighbor'
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
gem 'openssl'
gem 'parser', '3.2.2.4'
gem 'pg', '~> 1.4.6'
gem 'postmark-rails'
gem 'rack-cors', require: 'rack/cors'
gem 'rack-user_agent'
gem 'rails_autolink'
gem 'rails-i18n'
gem 'rails-patterns', '~> 0.2'
gem 'ransack', '~> 4.3'
gem 'solid_cache'
gem 'solid_queue'
# TODO: connection_pool互換性が修正された安定版リリース後にgem版に戻す
gem 'react-rails', github: 'reactjs/react-rails', ref: '224d03b8e04b95e4d16197fc6ecf75601543154a'
gem 'recaptcha', '~> 5.12'
gem 'rollbar'
gem 'rss'
gem 'ruby_llm'
gem 'ruby-openai'
gem 'rubyzip'
gem 'slim-rails'
gem 'sorcery', '~> 0.16.2'
gem 'sorcery-jwt'
gem 'stringio', '>= 3.1.3'
gem 'stripe'
gem 'stripe-i18n', git: 'https://github.com/komagata/stripe-i18n', branch: 'update-depencency'
gem 'switchlet'
gem 'tzinfo', '~> 2.0', '>= 2.0.6'
gem 'view_component'

group :development, :test do
  gem 'benchmark', require: false
  gem 'byebug', platforms: :windows
  gem 'dotenv-rails'
  gem 'pry-byebug'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-fjord', '~> 0.4.0', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'slim_lint'
  gem 'traceroute'
end

group :development do
  gem 'bullet'
  gem 'foreman'
  gem 'letter_opener_web', '~> 2.0'
  gem 'listen', '~> 3.3'
  gem 'rack-dev-mark'
  gem 'rack-mini-profiler', '~> 2.0', require: false
  gem 'view_source_map'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'minitest', '< 6.0'
  gem 'minitest-ci'
  gem 'minitest-retry'
  gem 'minitest-stub_any_instance'
  gem 'selenium-webdriver'
  gem 'vcr'
  gem 'webmock'
end
