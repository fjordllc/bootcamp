# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "capybara/rails"
require "webmock/minitest"
require "supports/stub_helper"

WebMock.disable_net_connect!(allow_localhost: true, allow: "chromedriver.storage.googleapis.com")
Webdrivers.cache_time = 86_400

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include StubHelper
end
