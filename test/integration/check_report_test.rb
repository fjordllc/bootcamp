require "test_helper"

class CheckReportTest < ActionDispatch::IntegrationTest
  test "non admin user is non botton" do
    login_user "tanaka", "testtest"

    assert_equal current_path, "/users"
    click_link "日報"
    assert_text "作業週2日目"
    click_link "作業週2日目"
    assert_not has_button? "日報を確認する"
  end

  test "Success Repost Checking" do
    login_user "machida", "testtest"

    assert_equal current_path, "/users"
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

  test "non button in current_user report" do
    login_user "komagata", "testtest"

    assert_equal current_path, "/users"
    click_link "日報"
    assert_text "作業週2日目"
    click_link "作業週2日目"
    assert_not has_button? "日報を確認する"
  end
end
