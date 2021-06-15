# frozen_string_literal: true

require 'application_system_test_case'

class LoginRequirementsTest < ApplicationSystemTestCase
  setup { @user_id = users(:hatsuno).id }

  test 'show listing user\'s comments' do
    visit "/users/#{@user_id}/comments"
    assert_text 'ログインしてください'
  end

  test 'show listing user\'s products' do
    visit "/users/#{@user_id}/products"
    assert_text 'ログインしてください'
  end

  test 'show listing user\'s reports' do
    visit "/users/#{@user_id}/reports"
    assert_text 'ログインしてください'
  end
end
