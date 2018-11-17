# frozen_string_literal: true

require "application_system_test_case"

class RequireLoginTest < ApplicationSystemTestCase
  test "users_path" do
    visit "/users"
    assert_text "ログインしてください"
  end

  test "questions_path" do
    visit "/questions"
    assert_equal "/", current_path
    assert_text "ログインしてください"
  end

  test "practices_path" do
    visit "/courses/#{courses(:course_1).id}/practices"
    assert_text "ログインしてください"
  end

  test "reports_path" do
    visit "/reports"
    assert_text "ログインしてください"
  end

  test "pages_path" do
    visit "/pages"
    assert_text "ログインしてください"
  end
end
