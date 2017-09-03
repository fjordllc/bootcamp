require "test_helper"

class PracticePageTest < ActionDispatch::IntegrationTest
  def setup
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "tanaka")
      fill_in("user[password]", with: "testtest")
      click_button "サインイン"
    end
  end

  test "existence complete button" do
    assert_equal current_path, "/users"
    click_link "プラクティス"
    click_link "rubyをインストールする"
    assert has_link? "完了"
    click_link "完了"
    assert_equal current_path, "/practices"
    click_link "rubyをインストールする"
    assert_not has_link? "完了"
  end

  test "Complete button does not exist if practice has assignment" do
    assert_equal current_path, "/users"
    click_link "プラクティス"
    click_link "viをインストールする"
    assert_not has_link? "完了"
    assert has_link? "課題の確認を依頼する"
    click_link "課題の確認を依頼する"
    assert_equal current_path, "/practices"
    click_link "viをインストールする"
    assert_not has_link? "課題の確認を依頼する"
  end
end
