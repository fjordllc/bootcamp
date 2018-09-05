require "application_system_test_case"

class CheckReportTest < ApplicationSystemTestCase
  test "non admin user is non botton" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "tanaka")
      fill_in("user[password]", with: "testtest")
    end
    click_button "サインイン"
    assert_equal "/users", current_path
    click_link "日報"
    assert_text "作業週2日目"
    click_link "作業週2日目"
    assert_not has_button? "日報を確認する"
  end

  test "Success Report Checking" do
    visit "/login"
    within("#sign-in-form") do
      fill_in("user[login_name]", with: "machida")
      fill_in("user[password]", with: "testtest")
    end
    click_button "サインイン"
    assert_equal "/users", current_path
    click_link "日報"
    assert_text "作業週2日目"
    click_link "作業週2日目"
    assert has_button? "日報を確認する"
    click_button "日報を確認する"
    assert_not has_button? "日報を確認する"
    assert_text "この日報を確認しました。"
    visit reports_path
    assert_text "確認済"
  end

  test "Success Adviser's Report Checking" do
    login_user "mineo", "testtest"
    assert_equal "/users", current_path
    click_link "日報"
    assert_text "作業週2日目"
    click_link "作業週2日目"
    assert has_button? "日報を確認する"
    click_button "日報を確認する"
    assert_not has_button? "日報を確認する"
    assert_text "この日報を確認しました。"
    visit reports_path
    assert_text "確認済"
  end
end
