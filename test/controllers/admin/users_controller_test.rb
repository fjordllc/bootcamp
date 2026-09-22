# frozen_string_literal: true

require 'test_helper'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test 'comeback from admin does not create a comebacked comment' do
    user = users(:kyuukai)

    assert_no_difference 'Comment.count' do
      patch admin_user_path(user, _login_name: 'komagata'), params: { user: { name: user.name }, comeback_user: '1' }
    end

    assert_nil user.reload.hibernated_at
  end
end
