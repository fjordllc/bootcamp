# frozen_string_literal: true

require "application_system_test_case"

class Admin::DiplomaTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "show diploma" do
    visit "/admin/diploma?user_id=#{users(:kimura).id}"
    assert_equal "#{users(:kimura).full_name}の卒業証書", title
  end
end
