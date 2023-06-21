# frozen_string_literal: true

require 'test_helper'

class GraduationControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test 'not admin permission requests for graduation' do
    token = create_token('kensyu', 'testtest')
    user = users(:kensyu)
    target = users(:hajime)

    post user_sessions_path, params: {
      authenticity_token: token, user: {
        login: user.login_name, password: 'testtest'
      }
    }
    follow_redirect!

    patch "/users/#{target.id}/graduation", params: {
      authenticity_token: token, user_id: target.id
    }
    follow_redirect!

    assert_equal '管理者としてログインしてください', '管理者としてログインしてください'
    assert_equal users(:hajime).graduated_on, nil
  end
end
