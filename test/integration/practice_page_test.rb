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
    assert has_button? "課題の確認を依頼する"
    fill_in("task_request_content", with: "課題が完了しました。宜しくお願い致します。")
    click_button "課題の確認を依頼する"
    assert_not has_link? "課題の確認を依頼する"
    assert_text "提出した課題の内容"
    assert_text "課題が完了しました。宜しくお願い致します。"
  end
end
