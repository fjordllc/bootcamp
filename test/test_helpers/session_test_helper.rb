# frozen_string_literal: true

module SessionTestHelper
  def sign_in(user)
    user = users(user) unless user.is_a? User
    post user_sessions_path, params: {
      user: {
        login: user.login_name,
        password: 'testtest'
      }
    }
  end

  def sign_out
    get logout_path
  end
end
