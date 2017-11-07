require "test_helper"

class SignInTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "success" do
    login_user "tanaka", "testtest"
    assert_equal current_path, "/users"
  end

  test "fail" do
    login_user "tanaka", "xxxxxxxx"
    assert_equal current_path, "/user_sessions"
    assert_text "インターン名かパスワードが違います。"
  end
end
