# frozen_string_literal: true

# ローカルでカバレッジを出さない場合、以下2行をコメントアウト
require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "capybara/rails"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
