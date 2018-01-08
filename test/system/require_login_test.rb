require "application_system_test_case"

class RequireLoginTest < ApplicationSystemTestCase
  test "users_path" do
    get "/users"
    assert_redirected_to "/welcome"
    assert_equal "ログインしてください", flash[:alert]
  end

  test "questions_path" do
    get "/questions"
    assert_redirected_to "/welcome"
    assert_equal "ログインしてください", flash[:alert]
  end

  test "practices_path" do
    get "/practices"
    assert_redirected_to "/welcome"
    assert_equal "ログインしてください", flash[:alert]
  end

  test "reports_path" do
    get "/reports"
    assert_redirected_to "/welcome"
    assert_equal "ログインしてください", flash[:alert]
  end

  test "pages_path" do
    get "/pages"
    assert_redirected_to "/welcome"
    assert_equal "ログインしてください", flash[:alert]
  end
end
