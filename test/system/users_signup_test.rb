require "application_system_test_case"

class UsersSignupTest < ApplicationSystemTestCase
  fixtures :users

  test "sign up" do
    visit "/"
    # 失敗するテスト
    assert_current_path("/users")
  end
end
