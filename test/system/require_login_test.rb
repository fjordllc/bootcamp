# frozen_string_literal: true

require 'application_system_test_case'

class RequireLoginTest < ApplicationSystemTestCase
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

  test 'users_path' do
    visit '/users'
    assert_text 'ログインしてください'
  end

  test 'questions_path' do
    visit '/questions'
    assert_equal '/', current_path
    assert_text 'ログインしてください'
  end

  test 'practices_path' do
    visit "/courses/#{courses(:course1).id}/practices"
    assert_text 'ログインしてください'
  end

  test 'reports_path' do
    visit '/reports'
    assert_text 'ログインしてください'
  end

  test 'pages_path' do
    visit '/pages'
    assert_text 'ログインしてください'
  end
end
