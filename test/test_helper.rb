# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'capybara/rails'
require 'vcr'
require 'supports/api_helper'

Webdrivers.cache_time = 86_400

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors) unless ENV['CI']

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  include Sorcery::TestHelpers::Rails::Integration
  include APIHelper
end

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: %i[method path query body]
  }
  c.before_record do |interaction|
    interaction.response.body.force_encoding 'UTF-8'
    body = JSON.pretty_generate(JSON.parse(interaction.response.body))
    interaction.response.body = body if interaction.response.body.present?
  end
end
