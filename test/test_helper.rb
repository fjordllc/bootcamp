# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'capybara/rails'
require 'vcr'
require 'minitest/retry'
require 'supports/api_helper'

Capybara.default_max_wait_time = 5
Capybara.disable_animation = true
Webdrivers.cache_time = 86_400
Minitest::Retry.use!

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  include Sorcery::TestHelpers::Rails::Integration
  include APIHelper
end

VCR.configure do |c|
  #c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock

  c.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: %i[method path query body]
  }

  c.before_record do |i|
    i.response.body.force_encoding 'UTF-8'
    if i.response.headers['Content-Type'].include? 'application/json'
      body = JSON.pretty_generate(JSON.parse(i.response.body))
      i.response.body = body if i.response.body.present?
    end
  end

  c.preserve_exact_body_bytes do |http_message|
    name = 'UTF-8' || !http_message.body.valid_encoding?
    http_message.body.encoding.name == name
  end

  driver_hosts = Webdrivers::Common.subclasses.map { |driver| URI(driver.base_url).host }
  c.ignore_hosts(*driver_hosts)
end
