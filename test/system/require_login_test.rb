require "application_system_test_case"

class RequireLoginTest < ApplicationSystemTestCase
  test "users_path" do
    visit "/users"
    assert_equal "/", current_path
    assert_text "ログインしてください"
  end

  test "questions_path" do
    visit "/questions"
    assert_equal "/", current_path
    assert_text "ログインしてください"
  end

  test "practices_path" do
    visit "/practices"
    assert_equal "/", current_path
    assert_text "ログインしてください"
  end

  test "reports_path" do
    visit "/reports"
    assert_equal "/", current_path
    assert_text "ログインしてください"
  end

  test "pages_path" do
    visit "/pages"
    assert_equal "/", current_path
    assert_text "ログインしてください"
  end
end
