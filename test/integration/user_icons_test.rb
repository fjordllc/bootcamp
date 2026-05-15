# frozen_string_literal: true

require 'test_helper'

class UserIconsTest < ActionDispatch::IntegrationTest
  fixtures :users

  test 'GET /@login_name.webp redirects to avatar for user with avatar' do
    user = users(:komagata)
    get "/@#{user.login_name}.webp"
    assert_response :redirect
  end

  test 'GET /@login_name.webp redirects to default icon for user without avatar' do
    user = users(:komagata)
    user.avatar.purge if user.avatar.attached?
    get "/@#{user.login_name}.webp"
    assert_response :redirect
    assert_includes response.location, '/images/users/avatars/default.png'
  end

  test 'GET /@nonexistent.webp redirects to default icon' do
    get '/@nonexistent_user_12345.webp'
    assert_response :redirect
    assert_includes response.location, '/images/users/avatars/default.png'
  end

  test 'response includes Cache-Control header' do
    get "/@#{users(:komagata).login_name}.webp"
    assert_includes response.headers['Cache-Control'], 'max-age=3600'
  end
end
