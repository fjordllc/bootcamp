# frozen_string_literal: true

require "application_system_test_case"

class API::GrassesTest < ApplicationSystemTestCase
  test "get grass" do
    login_user "tanaka", "testtest"
    visit "/api/grasses/#{users(:tanaka).id}.json"
    assert_text "velocity"
  end
end
