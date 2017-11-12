require "test_helper"

class PracticePageCompleteButtonTest < ActionDispatch::IntegrationTest
  test "has task should be empty complete button" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "komagata")
      fill_in("user[password]", with: "testtest")
    end
    click_button "サインイン"
    assert_equal current_path, "/users"
    click_link "プラクティス"
    click_link "PC性能の見方を知る"
    assert_not has_link? "完了"
    assert_text "課題の提出フォーム"
  end

  test "hasn't task should be existence complete button" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "komagata")
      fill_in("user[password]", with: "testtest")
    end
    click_button "サインイン"
    assert_equal current_path, "/users"
    click_link "プラクティス"
    click_link "Debianをインストールする"
    assert has_link? "完了"
    assert_no_text "課題の提出フォーム"
  end
end
