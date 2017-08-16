require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "sign up" do
    visit "/"
    assert_current_path("/")
  end
end
